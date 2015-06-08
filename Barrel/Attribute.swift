//
//  Attribute.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/07.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

internal class ManagedObjectAttribute : NSObject {
    
}

internal struct PropertyAttribute {
    let parentType: NSManagedObject.Type
    let keyPath: String
    init(parentType: NSManagedObject.Type, keyPath: String) {
        self.parentType = parentType
        self.keyPath = keyPath
    }
}

internal protocol PropertyAttributeCoder {
    static func codingAttribute(attribute: PropertyAttribute) -> Self
    func decodingAttribute() -> PropertyAttribute?
}

// TODO support many relationships
extension String : PropertyAttributeCoder {
    internal static func codingAttribute(attribute: PropertyAttribute) -> String {
        return "PropertyAttribute:\(attribute.parentType):\(attribute.keyPath)"
    }
    
    internal func decodingAttribute() -> PropertyAttribute? {
        let elements = self.componentsSeparatedByString(":")
        if elements.first == "PropertyAttribute" && elements.count == 3 {
            return PropertyAttribute(parentType: NSClassFromString(elements[1]) as! NSManagedObject.Type, keyPath: elements[2])
        }
        return nil
    }
}

internal extension NSManagedObject {
    internal class func attributeClass() -> AnyClass! {
        let className = NSStringFromClass(classForCoder()) + "Attribute"
        var attributeClass: AnyClass! = NSClassFromString(className)
        if attributeClass == nil {
            attributeClass = objc_allocateClassPair(ManagedObjectAttribute.self, className, 0)
            objc_registerClassPair(attributeClass)
            var propertyCount: UInt32 = 0
            var properties = class_copyPropertyList(classForCoder(), &propertyCount)
            for i in 0..<Int(propertyCount) {
                if let propertyName = String.fromCString(property_getName(properties[i])) {
                    let keyPath: @objc_block() -> AnyObject? = {
                        return String.codingAttribute(PropertyAttribute(parentType: self, keyPath: propertyName))
                    }
                    class_addMethod(attributeClass, Selector(propertyName), imp_implementationWithBlock(unsafeBitCast(keyPath, AnyObject.self)), "@@:")
                }
            }
        }
        return attributeClass
    }
    
    internal class func comparisonClass() -> AnyClass! {
        let className = NSStringFromClass(classForCoder()) + "Comparison"
        var comparisonClass: AnyClass! = NSClassFromString(className)
        if comparisonClass == nil {
            comparisonClass = objc_allocateClassPair(NSObject.self, className, 0)
            objc_registerClassPair(comparisonClass)
            var propertyCount: UInt32 = 0
            var properties = class_copyPropertyList(classForCoder(), &propertyCount)
            for i in 0..<Int(propertyCount) {
                if let propertyName = String.fromCString(property_getName(properties[i])) {
                    let keyPath: @objc_block() -> AnyObject? = {
                        return nil
                    }
                    class_addMethod(comparisonClass, Selector(propertyName), imp_implementationWithBlock(unsafeBitCast(keyPath, AnyObject.self)), "@@:")
                }
            }
        }
        return comparisonClass
    }
    
    class func attribute() -> Self {
        return unsafeBitCast(attributeClass().new(), self)
    }
    
    class func comparison() -> Self {
        return unsafeBitCast(comparisonClass().new(), self)
    }
}
