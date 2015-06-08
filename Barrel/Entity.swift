//
//  Entity.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/29.
//  Copyright (c) 2015 Nobuo Saito. All rights reserved.
//

import Foundation
import CoreData

// MARK: get entity name
var entityMapKey: Void?

private extension NSManagedObjectModel {
    private var entityMap: [String: String] {
        get {
            if let entityMap = objc_getAssociatedObject(self, &entityMapKey) as? [String: String] {
                return entityMap
            } else {
                self.entityMap = [:]
                return self.entityMap
            }
        }
        set {
            objc_setAssociatedObject(self, &entityMapKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    private func entityName(T: NSManagedObject.Type) -> String? {
        let className = NSStringFromClass(T)
        if let entityName = entityMap[className] {
            return entityName
        }
        if let entity = (entities as? [NSEntityDescription])?.filter({ className == $0.managedObjectClassName }).first {
            entityMap[className] = entity.name
            return entity.name
        }
        return nil
    }
}

internal extension NSManagedObjectContext {
    internal func entityName(T: NSManagedObject.Type) -> String? {
        if let coordinator = persistentStoreCoordinator, let entityName = coordinator.managedObjectModel.entityName(T) {
            return entityName
        }
        if let entityName = parentContext?.entityName(T) {
            return entityName
        }
        return nil
    }

    internal func entityDescription(T: NSManagedObject.Type) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(entityName(T)!, inManagedObjectContext: self)
    }
}

internal extension NSAttributeType {
    init(entityDescription: NSEntityDescription, keyPath: String) {
        if let attribute = entityDescription.attributesByName[keyPath] as? NSAttributeDescription {
            self = attribute.attributeType
        } else {
            self = .UndefinedAttributeType
        }
    }
}
