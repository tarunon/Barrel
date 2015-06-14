//
//  Insert.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/20.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData


public struct Insert<T: NSManagedObject> {
    internal typealias ManagedObjectBuilder = () -> T
    private let builder: ManagedObjectBuilder
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext) {
        self.context = context
        builder = { T(entity: context.entityDescription(T)!, insertIntoManagedObjectContext: context) }
    }
    
    private init(context: NSManagedObjectContext, builder: ManagedObjectBuilder) {
        self.context = context
        self.builder = builder
    }
}

extension Insert: Builder {
    func build() -> T {
        return builder()
    }
}

// MARK: insert
extension Insert {
    public func insert() -> T {
        let object = build()
        context.insertObject(object)
        return object
    }
    
    public func getOrInsert() -> T {
        let object = build()
        var fetch = context.fetch(T).filter{ $0 != object }
        for e in object.changedValues() {
            fetch = fetch.filter(NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: e.0 as! String), rightExpression: NSExpression(forConstantValue: e.1), modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .allZeros))
        }
        if let object2 = fetch.execute().get() {
            context.deleteObject(object)
            return object2
        }
        context.insertObject(object)
        return object
    }
}

// MARK: setup methods
public extension Insert {
    public func setValue(value: AnyObject, forKey key: String) -> Insert {
        return Insert(context: context, builder: builder >>> { (object: T) -> T in
            object.setPrimitiveValue(value, forKey: key)
            return object
            })
    }
    
    public func setValues(values: [AnyObject], forKeys keys: [String]) -> Insert {
        return Insert(context: context, builder: builder >>> { (object: T) -> T in
            for i in 0..<keys.count {
                object.setPrimitiveValue(values[i], forKey: keys[i])
            }
            return object
            })
    }
    
    public func setKeyedValues(keyedValues: [String: AnyObject]) -> Insert {
        return Insert(context: context, builder: builder >>> { (object: T) -> T in
            for e in keyedValues {
                object.setPrimitiveValue(e.1, forKey: e.0)
            }
            return object
            })
    }
}

// MARK: insert extension
public extension NSManagedObjectContext {
    public func insert<T: NSManagedObject>() -> Insert<T> {
        return Insert(context: self)
    }
    
    public func insert<T: NSManagedObject>(type: T.Type) -> Insert<T> {
        return insert()
    }
}

// MARK: setup methods via attribute
public extension Insert {
    public func setValues(atObject:(T) -> ()) -> Insert {
        return Insert(context: context, builder: builder >>> { (object: T) -> T in
            atObject(object)
            return object
            })
    }
}