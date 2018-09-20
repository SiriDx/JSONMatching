//
//  JSONMatching.swift
//  JSONMatching
//
//  Created by Dean on 2018/9/18.
//  Copyright © 2018年 Dean. All rights reserved.
//  代码地址:https://github.com/SiriDx/JSONMatching

import UIKit

public typealias CodableObject = NSObject & Codable

public class JSONMatching: NSObject {
    
    var objectPropertyMatching:((Any.Type) -> CodableObject?)?
    private var decoder:JSONDecoder = JSONDecoder()
    
    /// 字典 转 模型
    /// Create a 'CodableObject' type object from '[String:Any?]' type dictionary.
    public func object<T:CodableObject>(type:T.Type, with dic:[String:Any?]) -> T? {
        if !JSONSerialization.isValidJSONObject(dic) { return nil }
        let newDic = dataDecode(dic: dic, mirror: Mirror.init(reflecting: T()))
        if !JSONSerialization.isValidJSONObject(newDic) { return nil }
        if let data = try? JSONSerialization.data(withJSONObject: newDic, options: .prettyPrinted) {
            if let obj = try? decoder.decode(T.self, from: data) {
                return obj
            }
        }
        return nil
    }
    
    /// JSON字符串 转 模型
    /// Create a 'CodableObject' type object from JSON string
    public func object<T:CodableObject>(type:T.Type, with jsonString:String) -> T? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let dic = jsonObj as? [String:Any?] {
            
            let newDic = dataDecode(dic: dic, mirror: Mirror.init(reflecting: T()))
            
            if !JSONSerialization.isValidJSONObject(newDic) { return nil }
            if let data = try? JSONSerialization.data(withJSONObject: newDic, options: .prettyPrinted) {
                if let obj = try? decoder.decode(T.self, from: data) {
                    return obj
                }
            }
        }
        return nil
    }
    
    /// 字典数组 转 模型数组
    /// Create a 'CodableObject' type object array from '[[String:Any]]' type dictionary array.
    public func objectArray<T:CodableObject>(type:[T].Type, with arr:[[String:Any?]]) -> [T]? {
        if !JSONSerialization.isValidJSONObject(arr) { return nil }
        
        var newArr = [[String:Any?]]()
        for objDic in arr {
            let newDic = dataDecode(dic: objDic, mirror: Mirror.init(reflecting: T()))
            newArr.append(newDic)
        }
        
        if !JSONSerialization.isValidJSONObject(newArr) { return nil }
        if let data = try? JSONSerialization.data(withJSONObject: newArr, options: .prettyPrinted) {
            if let obj = try? decoder.decode([T].self, from: data) {
                return obj
            }
        }
        return nil
    }
    
    /// 模型属性: 根据类型(Any.Type), 提供一个该类型对应的模型对象
    /// Object property, returns a 'CodableObject' object with specific type
    public func codableObjectForProperty(matching:@escaping ((Any.Type) -> CodableObject?)) {
        self.objectPropertyMatching = matching
    }
    
    /// 自定义模型属性名
    ///
    /// - Parameter customKeys: [自定义属性名:数据属性名]
//    func exchangeKeys(customKeys:[String:String]) {
//        decoder.keyDecodingStrategy = .custom({ (codingKeys:[CodingKey]) -> CodingKey in
//            let codeKey = codingKeys.last!
//            print(codingKeys)
//            let key = codeKey.stringValue
//            if let newKey = customKeys[key] {
//                let newCodeKey = MatchCodingKey(stringValue: newKey)
//                return newCodeKey
//            }
//            return codeKey
//        })
//    }
    
}

extension JSONMatching {
    func dataDecode(dic:[String:Any?], mirror:Mirror) -> [String:Any?] {
        
        var decodedDic = dic
        for (label, propertyValue) in mirror.children {
            
            guard let propertyName = label else { continue }
            guard let dicValue = dic[propertyName] else {
                decodedDic[propertyName] = dicByAdding(key: propertyName, value: propertyValue)
                continue
            }
            
            guard let dataValue = dicValue else { continue }

            let propertyType = type(of: propertyValue)
            let dataValueType = type(of: dataValue)
            guard dataValueType != propertyType else { continue }
            
            var newDataValue:Any?
            
            if var dataValueDic = dataValue as? [String:Any?] { // 字典
                
                if propertyValue is CodableObject {
                    let mirror = Mirror.init(reflecting: propertyValue)
                    dataValueDic = dataDecode(dic: dataValueDic, mirror: mirror)
                    newDataValue = dataValueDic
                } else {
                    if let objDecoding = objectPropertyMatching, let obj = objDecoding(propertyType)  {
                        let mirror = Mirror.init(reflecting: obj)
                        dataValueDic = dataDecode(dic: dataValueDic, mirror: mirror)
                        newDataValue = dataValueDic
                    }
                }
                
            } else if let dataArrValues = dataValue as? [[String:Any?]] { // 字典数组
                
                if let objDecoding = objectPropertyMatching, let obj = objDecoding(propertyType)  {
                    var newArr = [[String:Any?]]()
                    for objDic in dataArrValues {
                        let newDic = dataDecode(dic: objDic, mirror: Mirror.init(reflecting: obj))
                        newArr.append(newDic)
                    }
                    newDataValue = newArr
                }
                
            } else if let dataArrValues = dataValue as? [Any] { //数组
                
                newDataValue = newArrValueMatching(oldValueArr: dataArrValues, with: propertyType)
                
            } else { // 其他
                newDataValue = newValueMatching(propertyType, with: dataValue)
            }
            
            if let newValue = newDataValue {
                decodedDic[propertyName] = newValue
            } else {
                decodedDic[propertyName] = propertyValue
            }
            
        }
        
        return decodedDic
    }
    
    func newArrValueMatching(oldValueArr:[Any], with propertyType:Any.Type) -> [Any]? {
        
        var newArrValues:[Any]?
        if propertyType == [String].self || propertyType == [String]?.self {
            var strValues = [String]()
            if let oldValueNumArr = oldValueArr as? [NSNumber] {
                for oldValueNum in oldValueNumArr {
                    // NSNumber => String
                    let numFmt = NumberFormatter()
                    numFmt.numberStyle = .decimal
                    if let newValue = numFmt.string(from: oldValueNum) {
                        strValues.append(newValue)
                    }
                }
            }
            newArrValues = strValues
            
        } else {
            
            var opElementType:(Any.Type)?
            
            if propertyType == [Int8].self || propertyType == [Int8]?.self {
                opElementType = Int8.self
            } else if propertyType == [UInt8].self || propertyType == [UInt8]?.self {
                opElementType = UInt8.self
            } else if propertyType == [Int16].self || propertyType == [Int16]?.self {
                opElementType = Int16.self
            } else if propertyType == [UInt16].self || propertyType == [UInt16]?.self {
                opElementType = UInt16.self
            } else if propertyType == [Int32].self || propertyType == [Int32]?.self {
                opElementType = Int32.self
            } else if propertyType == [Int64].self || propertyType == [Int64]?.self {
                opElementType = Int64.self
            } else if propertyType == [UInt64].self || propertyType == [UInt64]?.self {
                opElementType = UInt64.self
            } else if propertyType == [Float].self || propertyType == [Float]?.self {
                opElementType = Float.self
            } else if propertyType == [Double].self || propertyType == [Double]?.self {
                opElementType = Double.self
            } else if propertyType == [Bool].self || propertyType == [Bool]?.self {
                opElementType = Bool.self
            } else if propertyType == [Int].self || propertyType == [Int]?.self {
                opElementType = Int.self
            } else if propertyType == [UInt].self || propertyType == [UInt]?.self {
                opElementType = UInt.self
            }
            
            if let elementType = opElementType {
                var newArr = [Any]()
                for oldValue in oldValueArr {
                    if let newValue = newValueMatching(elementType, with: oldValue) {
                        newArr.append(newValue)
                    }
                }
                newArrValues = newArr
            }
            
        }
        return newArrValues
    }
    
    func newValueMatching(_ propertyType:Any.Type, with oldValue:Any) -> Any? {
        
        var newValue:Any?
        
        if propertyType == String.self || propertyType == String?.self {
            
            // NSNumber => String
            if let oldValueNum = oldValue as? NSNumber {
                let numFmt = NumberFormatter()
                numFmt.numberStyle = .decimal
                newValue = numFmt.string(from: oldValueNum)
            } else if let oldValueStr = oldValue as? NSString {
                newValue = oldValueStr
            }
            
        } else if let propertyNumType = MatchNumType.init(type: propertyType) {
            
            if let oldValueNum = oldValue as? NSNumber {
                // NSNumber => BasicNum
                newValue = propertyNumType.value(num: oldValueNum)
            } else if let oldValueStr = oldValue as? String {
                // String => BasicNum
                newValue = propertyNumType.value(str: oldValueStr)
            }
        }
        
        return newValue
    }
    
    private func dicByAdding(key:String, value:Any) -> Any {
        if value is CodableObject {
            var objDic = [String:Any]()
            let propertyMirror = Mirror.init(reflecting: value)
            for (childLabel, childValue) in propertyMirror.children {
                if let childKey = childLabel {
                    objDic[childKey] = dicByAdding(key: childKey, value: childValue)
                }
            }
            return objDic
        } else {
            return value
        }
    }
    
}

private struct MatchCodingKey : CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

private enum MatchNumType:String {
    case Int8
    case UInt8
    case Int16
    case UInt16
    case Int32
    case UInt32
    case Int64
    case UInt64
    case Float
    case Double
    case Bool
    case Int
    case UInt
    
    init?(type:Any.Type) {
        var rawValue = String(describing: type)
        if rawValue.contains("Optional") {
            rawValue = rawValue.components(separatedBy: "Optional<").last?.components(separatedBy: ">").first ?? ""
        }
        self.init(rawValue: rawValue)
    }
    
    func value(str:String) -> Any? {
        let numFmt = NumberFormatter()
        numFmt.numberStyle = .decimal
        if let num = numFmt.number(from: str) {
            return value(num: num)
        }
        return nil
    }
    
    func value(num:NSNumber) -> Any {
        switch self {
        case .Int8:
            return num.int8Value
        case .UInt8:
            return num.uint8Value
        case .Int16:
            return num.int16Value
        case .UInt16:
            return num.uint16Value
        case .Int32:
            return num.int32Value
        case .UInt32:
            return num.uint32Value
        case .Int64:
            return num.int64Value
        case .UInt64:
            return num.uint64Value
        case .Float:
            return num.floatValue
        case .Double:
            return num.doubleValue
        case .Bool:
            return num.boolValue
        case .Int:
            return num.intValue
        case .UInt:
            return num.uintValue
        }
    }
}
