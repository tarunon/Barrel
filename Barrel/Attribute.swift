//
//  Attribute.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/07.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

public protocol AttributeType {
    
}

extension NSObject: AttributeType {
    
}

extension String: AttributeType {
    
}

extension Set: AttributeType {
    
}

internal enum Attribute {
    case KeyPath(String)
    case Value(AnyObject)
    case Null
    case Unsupported
    
    init(value: Any?) {
        if let _ = value as? AttributeManagedObject {
            self = .KeyPath("self")
        } else if let relationship = value as? RelationshipManagedObject {
            self = .KeyPath(relationship.property.decodingProperty()!.keyPath)
        } else if let set = value as? NSSet, let relationship = set.anyObject() as? RelationshipManagedObject {
            self = .KeyPath(relationship.property.decodingProperty()!.keyPath)
        } else if let string = value as? String, let attribute = string.decodingProperty() {
            self = .KeyPath(attribute.keyPath)
        } else if let object: AnyObject = value as? AnyObject {
            self = .Value(object)
        } else if value == nil {
            self = .Null
        } else {
            self = .Unsupported
        }
    }
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
                    propertyDescription.defaultValue = NSManagedObject(entity: relationshipDescription.destinationEntity!.relationshipEntityDescription(keyPath), insertIntoManagedObjectContext: nil)
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
    
    func comparisonEntityDescription() -> NSEntityDescription {
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
var comparisonMapKey: Void

internal extension NSManagedObjectModel {
    private var attributeEntityDescriptions: [String: NSManagedObject] {
        get {
            return associatedValueOrDefault(&attributeMapKey, defaultValue: [:])
        }
        set {
            objc_setAssociatedObject(self, &attributeMapKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var comparisonEntityDescriptions: [String: NSManagedObject] {
        get {
            return associatedValueOrDefault(&comparisonMapKey, defaultValue: [:])
        }
        set {
            objc_setAssociatedObject(self, &comparisonMapKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

internal extension NSManagedObjectContext {
    func attribute<T: NSManagedObject>(type: T.Type) -> T {
        return attribute()
    }
    
    func attribute<T: NSManagedObject>() -> T {
        if let object = managedObjectModel()?.attributeEntityDescriptions[NSStringFromClass(T.self)] as? T {
            return object
        }
        let object = T(entity: self.entityDescription(T)!.attributeEntityDescription(), insertIntoManagedObjectContext: nil)
        managedObjectModel()?.attributeEntityDescriptions[NSStringFromClass(T.self)] = object
        return object
    }
    
    func comparison<T: NSManagedObject>(type: T.Type) -> T {
        return comparison()
    }
    
    func comparison<T: NSManagedObject>() -> T {
        if let object = managedObjectModel()?.comparisonEntityDescriptions[NSStringFromClass(T.self)] as? T {
            return object
        }
        let object = T(entity: self.entityDescription(T)!.comparisonEntityDescription(), insertIntoManagedObjectContext: nil)
        managedObjectModel()?.comparisonEntityDescriptions[NSStringFromClass(T.self)] = object
        return object
    }
}
