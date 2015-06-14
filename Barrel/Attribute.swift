//
//  Attribute.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/07.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

// Unwrap Any using MirrorType
// http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type
internal func unwrapImplicitOptional(any: Any) -> Any? {
    let mirror = reflect(any)
    if mirror.disposition != .Optional {
        return any
    }
    if mirror.count == 0 {
        return nil
    }
    return mirror[0].1.value
}

internal class AttributeManagedObject: NSManagedObject {
    
}

internal class RelationshipManagedObject: NSManagedObject {
    @NSManaged var property: String
}

internal class Property {
    let keyPath: String
    init(keyPath: String) {
        self.keyPath = keyPath
    }
}

internal protocol PropertyCoder {
    static func codingProperty(attribute: Property) -> Self
    func decodingProperty() -> Property?
}

extension String : PropertyCoder {
    internal static func codingProperty(property: Property) -> String {
        return "PropertyAttribute:\(property.keyPath)"
    }
    
    internal func decodingProperty() -> Property? {
        let elements = self.componentsSeparatedByString(":")
        if elements.first == "PropertyAttribute" && elements.count == 2 {
            return Property(keyPath: elements[1])
        }
        return nil
    }
}

internal extension NSEntityDescription {
    func attributeEntityDescription() -> NSEntityDescription {
        let entityDescription = NSEntityDescription()
        entityDescription.name = name! + "Attribute"
        entityDescription.managedObjectClassName = NSStringFromClass(AttributeManagedObject.self)
        entityDescription.properties = properties.map({ (basePropertyDescription: NSPropertyDescription) -> NSPropertyDescription in
            let propertyDescription = NSAttributeDescription()
            let keyPath = basePropertyDescription.name
            propertyDescription.name = keyPath
            propertyDescription.attributeType = .TransformableAttributeType
            if let _ = basePropertyDescription as? NSAttributeDescription {
                propertyDescription.defaultValue = String.codingProperty(Property(keyPath: keyPath))
            } else if let relationshipDescription = basePropertyDescription as? NSRelationshipDescription {
                if relationshipDescription.toMany {
                    propertyDescription.defaultValue = Set(arrayLiteral: NSManagedObject(entity: relationshipDescription.destinationEntity!.relationshipEntityDescription(keyPath), insertIntoManagedObjectContext: nil))
                } else {
                    propertyDescription.defaultValue = String.codingProperty(Property(keyPath: keyPath))
                }
            }
            return propertyDescription
        })
        return entityDescription
    }
    
    func relationshipEntityDescription(keyPath: String) -> NSEntityDescription {
        let entityDescription = NSEntityDescription()
        entityDescription.name = name! + "Relationship"
        entityDescription.managedObjectClassName = NSStringFromClass(RelationshipManagedObject.self)
        let attributeDescription = NSAttributeDescription()
        attributeDescription.name = "property"
        attributeDescription.defaultValue = String.codingProperty(Property(keyPath: keyPath))
        entityDescription.properties = [attributeDescription]
        return entityDescription
    }
    
    func comparesionEntityDescription() -> NSEntityDescription {
        let entityDescription = NSEntityDescription()
        entityDescription.name = name! + "Comparession"
        entityDescription.properties = properties.map({ (basePropertyDescription: NSPropertyDescription) -> NSPropertyDescription in
            let propertyDescription = NSAttributeDescription()
            propertyDescription.name = basePropertyDescription.name
            propertyDescription.optional = true
            return propertyDescription
        })
        return entityDescription
    }
}

var attributeMapKey: Void?
var comparesionMapKey: Void

internal extension NSManagedObjectContext {
    
    private var attributeMap: [String: NSManagedObject] {
        get {
            if let attributeMap = objc_getAssociatedObject(self, &attributeMapKey) as? [String: NSManagedObject] {
                return attributeMap
            } else {
                self.attributeMap = [:]
                return self.attributeMap
            }
        }
        set {
            objc_setAssociatedObject(self, &attributeMapKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var comparesionMap: [String: NSManagedObject] {
        get {
            if let comparitionMap = objc_getAssociatedObject(self, &comparesionMapKey) as? [String: NSManagedObject] {
                return comparitionMap
            } else {
                self.comparesionMap = [:]
                return self.comparesionMap
            }
        }
        set {
            objc_setAssociatedObject(self, &comparesionMapKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func attribute<T: NSManagedObject>(type: T.Type) -> T {
        return attribute()
    }
    
    func attribute<T: NSManagedObject>() -> T {
        if let object = attributeMap[NSStringFromClass(T.self)] as? T {
            return object
        }
        let object = T(entity: self.entityDescription(T)!.attributeEntityDescription(), insertIntoManagedObjectContext: nil)
        attributeMap[NSStringFromClass(T.self)] = object
        return object
    }
    
    func comparesion<T: NSManagedObject>(type: T.Type) -> T {
        return comparesion()
    }
    
    func comparesion<T: NSManagedObject>() -> T {
        if let object = comparesionMap[NSStringFromClass(T.self)] as? T {
            return object
        }
        let object = T(entity: self.entityDescription(T)!.comparesionEntityDescription(), insertIntoManagedObjectContext: nil)
        comparesionMap[NSStringFromClass(T.self)] = object
        return object
    }
}
