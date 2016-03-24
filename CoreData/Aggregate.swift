//
//  Aggregate.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData
import Barrel

internal extension NSAttributeType {
    init<E: ExpressionType>(type: E.Type) {
        if E.ValueType.self is Int.Type {
            self = .Integer16AttributeType
        } else if E.ValueType.self is NSNumber.Type {
            self = .DoubleAttributeType
        } else if E.ValueType.self is String.Type {
            self = .StringAttributeType
        } else if E.ValueType.self is NSDate.Type {
            self = .DateAttributeType
        } else if E.ValueType.self is NSData.Type {
            self = .BinaryDataAttributeType
        } else {
            self = .UndefinedAttributeType
        }
    }
}

internal extension Expression {
    func expressionDescription() -> NSExpressionDescription {
        let expressionDescription = NSExpressionDescription()
        expressionDescription.expression = self.value
        expressionDescription.name = "\(self.value)"
        expressionDescription.expressionResultType = NSAttributeType(type: T.self)
        return expressionDescription
    }
}

public struct Aggregate<T: NSManagedObject where T: ExpressionType> {
    public let context: NSManagedObjectContext
    internal let builder: Builder<NSFetchRequest>
    
    private init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>) {
        self.context = context
        self.builder = builder
    }
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>, @autoclosure(escaping) expressionDescription: () -> NSExpressionDescription) {
        self.init(context: context, builder: {
            $0.resultType = .DictionaryResultType
            $0.propertiesToFetch = [expressionDescription()]
            return $0
        } </> builder)
    }
}

extension Aggregate: Executable {
    public typealias Type = [String: AnyObject]
    
    public func fetchRequest() -> NSFetchRequest {
        let fetchRequest = self.builder.build()
        if Barrel.debugMode {
            print("NSFetchRequest generated: \(fetchRequest)")
        }
        return fetchRequest
    }
}

public extension Aggregate {
    func aggregate(@autoclosure(escaping) expressionDescription: () -> NSExpressionDescription) -> Aggregate {
        return Aggregate(context: context, builder: {
            $0.propertiesToFetch = $0.propertiesToFetch! + [expressionDescription()]
            return $0
        } </> builder)
    }
}

public extension Aggregate {
    func brl_aggregate<E: ExpressionType, V: ExpressionType where E.ValueType == V>(f: Attribute<T> -> E) -> Aggregate {
        return self.aggregate(unwrapExpression(f(Attribute())).expressionDescription())
    }
}

public extension Fetch {
    func aggregate(@autoclosure(escaping) expressionDescription: () -> NSExpressionDescription) -> Aggregate<T> {
        return Aggregate(context: context, builder: builder, expressionDescription: expressionDescription)
    }
}

public extension Fetch {
    func brl_aggregate<E: ExpressionType, V: ExpressionType where E.ValueType == V>(f: Attribute<T> -> E) -> Aggregate<T> {
        return self.aggregate(unwrapExpression(f(Attribute())).expressionDescription())
    }
}
