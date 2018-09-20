//
//  ViewController.swift
//  Example
//
//  Created by Dean on 2018/9/18.
//  Copyright © 2018年 Dean. All rights reserved.
//

import UIKit
import JSONMatching

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        dicToObject()
//        dicToObject2()
//        jsonStrToObj()
//        dicToObject3()
        dicArrToObjectArr()
    }

}

extension ViewController {
    
    func jsonStrToObj() {
        
        let jsonStr = """
        {
            "name": "aaa",
            "age": 18,
            "height": 166
        }
        """
        
        let match = JSONMatching()
        let user = match.object(type: User.self, with: jsonStr)
        dump(user)
    }
    
    func dicToObject() {
        let dic:[String:Any] = [
            "name":"jack",
            "age":18,
            "height":1.88,
            "male":true
        ]
        
        let match = JSONMatching()
        let user = match.object(type: User.self, with: dic)
        dump(user)
    }
    
    func dicToObject2() {
        
        let dic:[String:Any] = [
            "name":"jack",
            "age":18,
            "height":1.88,
            "male":true,
            "pet": [
                "name":"micky",
                "type":"cat",
            ]
        ]
        
        let match = JSONMatching()
        
        /*
        // if property 'pet' is optional, provide a relative object
        match.codableObjectForProperty { (type) -> CodableObject? in
            if type == Pet?.self {
                return Pet()
            }
            return nil
        }
         */
 
        let user = match.object(type: User.self, with: dic)
        dump(user)
    }
    
    func dicToObject3() {
        
        let dic:[String:Any] = [
            "name":"jack",
            "age":18,
            "height":1.88,
            "male":true,
            "pet": [
                "name":"micky",
                "type":"cat",
            ],
            "cars":[
                ["brand":"BMW", "color":"yellow"],
                ["brand":"Benz", "color":"silver"]
            ],
            "children":[
                ["name":"jim", "age":5, "male":true],
                ["name":"lily", "age":2, "male":false]
            ]
        ]
        
        let match = JSONMatching()
        
        match.codableObjectForProperty { (type) -> CodableObject? in
            
            if type == [Car].self {
                return Car()
            } else if type == [Child]?.self  {
                return Child()
            }
            return nil
        }
        
        let user = match.object(type: User.self, with: dic)
        dump(user)
        
    }
    
    func dicArrToObjectArr() {
        
        let userArray:[[String:Any]] = [
            ["name":"jack", "age":18, "height":1.88, "male":true],
            ["name":"lily", "age":18, "height":1.65, "male":false],
            ["name":"josh", "age":30, "height":1.77, "male":true],
        ]
        
        let match = JSONMatching()
        let userArr = match.objectArray(type: [User].self, with: userArray)
        dump(userArr)
        
    }
    
}

