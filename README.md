# JSONMatching

![CocoaPods](https://img.shields.io/cocoapods/v/JSONMatching.svg)
![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-333333.svg)
![Swift](https://img.shields.io/badge/Swift-4.2-orange.svg)

An easy way to decode JSON data into Model object in pure Swift

1. [Requirements](#requirements)
2. [Integration](#integration)
3. [Usage](#usage)
- [Basics](#basics)
- [JSONString](#jsonstring)
- [Object Array](#object-array)
- [Object Property](#object-property)
- [Object Array Property](#object-array-property)

## Requirements

- iOS 8.0+
- Xcode 8

## Integration

#### CocoaPods (iOS 8+)

You can use [CocoaPods](http://cocoapods.org/) to install `JSONMatching` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
pod 'JSONMatching', '~> 1.0.0'
end
```

#### Manually (iOS 7+)

To use this library in your project manually you may:  

1. for Projects, just drag JSONMatching.swift to the project tree
2. for Workspaces, include the whole JSONMatching.xcodeproj

## Usage

#### Basics
To support deserialization from JSON, a class need to inherited from 'CodableObject'.

```swift
import JSONMatching
```

```swift
class User: CodableObject {
    var name:String = ""
    var age:Int = 0
    var height:Double = 0
}

let dic:[String:Any] = [
    "name":"jack",
    "age":18,
    "height":1.88,
    "male":true
]

let match = JSONMatching()
if let user = match.object(type: User.self, with: dic) {
    //...
}
```
#### JSONString

```swift
let jsonStr = """
    {
    "name": "aaa",
    "age": 18,
    "height": 166
    }
    """
    
let match = JSONMatching()
if let user = match.object(type: User.self, with: jsonStr) {
    //...
}   
    
```

#### Object Array

```swift
class User: CodableObject {
    var name:String = ""
    var age:Int = 0
    var height:Double = 0
}

let userArray:[[String:Any]] = [
    ["name":"jack", "age":18, "height":1.88, "male":true],
    ["name":"lily", "age":18, "height":1.65, "male":false],
    ["name":"josh", "age":30, "height":1.77, "male":true]
]

let match = JSONMatching()
if let userArr = match.objectArray(type: [User].self, with: userArray) {
    //...
}
```

#### Object Property

Object properties declared in class should be initialise. if not, use 'codableObjectForProperty' to provide a relative object

```swift

class User: CodableObject {
    var name:String = ""
    var age:Int = 0
    var height:Double = 0
    var pet:Pet = Pet()
    
    class Pet: CodableObject {
        var type:String = ""
        var name:String = ""
        var age:Int = 0
    }
}

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

/*
// if property 'pet' is optional, provide a relative object
match.codableObjectForProperty { (type) -> CodableObject? in
    if type == Pet?.self {
        return Pet()
    }
    return nil
}
*/

if let user = match.object(type: User.self, with: dic) {
    //...
}

```

#### Object Array Property

Use 'codableObjectForProperty' to provide a relative object for object array properties declared in class  

```swift

class User: CodableObject {
    var name:String = ""
    var age:Int = 0
    var height:Double = 0
    
    var cars:[Car] = [Car]()
    class Car: CodableObject {
        var brand:String = ""
        var color:String = ""
        var price:Double = 0
    }
    
    var children:[Child]?
    class Child: CodableObject {
        var name:String = ""
        var age:Int = 0
        var male:Bool?
    }
}

let match = JSONMatching()
match.codableObjectForProperty { (type) -> CodableObject? in
    if type == [Car].self {
        return Car()
    } else if type == [Child]?.self  {
        return Child()
    }
    return nil
}

if let user = match.object(type: User.self, with: dic) {
    //...
}

```


