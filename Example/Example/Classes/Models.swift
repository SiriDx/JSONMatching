//
//  Models.swift
//  Example
//
//  Created by Dean on 2018/9/18.
//  Copyright © 2018年 Dean. All rights reserved.
//

import UIKit
import JSONMatching

class User: CodableObject {
    var name:String = ""
    var age:Int = 0
    var height:Double = 0
    var male:Bool = false
    var pet:Pet = Pet()
    
    var cars:[Car] = [Car]()
    var children:[Child]?
}

class Pet: CodableObject {
    var type:String = ""
    var name:String = ""
    var age:Int = 10
}

class Car: CodableObject {
    var brand:String = ""
    var color:String = ""
    var price:Double = 0
}

class Child: CodableObject {
    var name:String = ""
    var age:Int = 0
    var male:Bool?
    var hobby:String = ""
}
