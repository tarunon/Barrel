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
    internal let builder: Builder<T>
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext) {
        self.context = context
        builder = Builder(T(entity: context.entityDescription(T)!, insertIntoManagedObjectContext: context))
    }
    
    private init(context: NSManagedObjectContext, builder: Builder<T>) {
        self.context = context
        self.builder = builder
    }
    
    func build() -> T {
        return builder.build()
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
        let fetch = reduce(object.changedValues(), context.fetch(T).filter(NSPredicate(format: "self != %@", argumentArray: [object]))) { 
            $0.0.filter(NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: $0.1.0 as! String), rightExpression: NSExpression(forConstantValue: $0.1.1), modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .allZeros))
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
        return Insert(context: context, builder: {
            $0.setPrimitiveValue(value, forKey: key)
            return $0
        } </> builder)
    }
    
    public func setValues(values: [AnyObject], forKeys keys: [String]) -> Insert {
        return Insert(context: context, builder: {
            for i in 0..<keys.count {
                $0.setPrimitiveValue(values[i], forKey: keys[i])
            }
            return $0
        } </> builder)
    }
    
    public func setKeyedValues(keyedValues: [String: AnyObject]) -> Insert {
        return Insert(context: context, builder: {
            for e in keyedValues {
                $0.setPrimitiveValue(e.1, forKey: e.0)
            }
            return $0
        } </> builder)
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
    public func setValues(atObject: T -> ()) -> Insert {
        return Insert(context: context, builder: builder.map {
            atObject($0)
            return $0
        })
    }
}