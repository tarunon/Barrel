//
//  Extensions.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData
import Barrel

// MARK: associated util
internal extension NSObject {
    internal func associatedValueOrDefault<T>(_ key: UnsafeRawPointer, defaultValue: @autoclosure() -> T) -> T {
        if let value = objc_getAssociatedObject(self, key) as? T {
            return value
        } else {
            let value = defaultValue()
            objc_setAssociatedObject(value as AnyObject, key, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
    }
}

// MARK: get entity name
var entityMapKey: Void?

fileprivate extension NSManagedObjectModel {
    private var entityNames: [String: String] {
        get {
            return associatedValueOrDefault(&entityMapKey, defaultValue: [:])
        }
        set {
            objc_setAssociatedObject(self, &entityMapKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate func entityName(_ T: NSManagedObject.Type) -> String? {
        let className = NSStringFromClass(T)
        if let entityName = entityNames[className] {
            return entityName
        }
        if let entity = entities.filter({ className == $0.managedObjectClassName }).first {
            entityNames[className] = entity.name
            return entity.name
        }
        return nil
    }
}


internal extension NSManagedObjectContext {
    internal func managedObjectModel() -> NSManagedObjectModel? {
        if let coordinator = persistentStoreCoordinator {
            return coordinator.managedObjectModel
        } else if let parent = parent {
            return parent.managedObjectModel()
        }
        return nil
    }
}

internal extension NSManagedObjectContext {
    internal func entityName(_ T: NSManagedObject.Type) -> String? {
        return managedObjectModel()?.entityName(T)
    }
    
    internal func entityDescription(_ T: NSManagedObject.Type) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName(T)!, in: self)
    }
}

extension NSManagedObject: ExpressionType {
    public typealias ValueType = NSManagedObject
}

public struct Many<T: NSManagedObject>: ExpressionType, ManyType {
    public typealias ValueType = Set<T>
    public typealias _ElementType = ExpressionWrapper<T>
}

public protocol ManagedObjectType {

}

extension NSManagedObject: ManagedObjectType {

}

extension ManagedObjectType where Self: NSManagedObject {
    public static func objects(_ context: NSManagedObjectContext) -> Fetch<Self> {
        return Fetch(context: context)
    }

    public static func insert(_ context: NSManagedObjectContext) -> Self {
        return Self(entity: context.entityDescription(Self.self)!, insertInto: context)
    }
}
