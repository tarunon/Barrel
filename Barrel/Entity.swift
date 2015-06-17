//
//  Entity.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/29.
//  Copyright (c) 2015 Nobuo Saito. All rights reserved.
//

import Foundation
import CoreData

// MARK: associated util
internal extension NSObject {
    internal func associatedValueOrDefault<T>(key: UnsafePointer<Void>, @autoclosure defaultValue: () -> T) -> T {
        if let value = objc_getAssociatedObject(self, key) as? T {
            return value
        } else {
            let value = defaultValue()
            objc_setAssociatedObject(value as! AnyObject, key, self, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return value
        }
    }
}

// MARK: get entity name
var entityMapKey: Void?

private extension NSManagedObjectModel {
    private var entityNames: [String: String] {
        get {
            return associatedValueOrDefault(&entityMapKey, defaultValue: [:])
        }
        set {
            objc_setAssociatedObject(self, &entityMapKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func entityName(type: NSManagedObject.Type) -> String? {
        let className = NSStringFromClass(type)
        if let entityName = entityMap[className] {
            return entityName
        }
        if let entity = entities.filter({ className == $0.managedObjectClassName }).first {
            entityMap[className] = entity.name
            return entity.name
        }
        return nil
    }
}

internal extension NSManagedObjectContext {
    internal func entityName(type: NSManagedObject.Type) -> String? {
        if let coordinator = persistentStoreCoordinator, let entityName = coordinator.managedObjectModel.entityName(type) {
            return entityName
        }
        if let entityName = parentContext?.entityName(type) {
            return entityName
        }
        return nil
    }
}

internal extension NSManagedObjectContext {
    internal func entityName(T: NSManagedObject.Type) -> String? {
        return managedObjectModel()?.entityName(T)
    }

    internal func entityDescription(T: NSManagedObject.Type) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(entityName(T)!, inManagedObjectContext: self)
    }
}

internal extension NSAttributeType {
    init(entityDescription: NSEntityDescription, keyPath: String) {
        if let attribute = entityDescription.attributesByName[keyPath] {
            self = attribute.attributeType
        } else {
            self = .UndefinedAttributeType
        }
    }
}
