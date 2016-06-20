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
            self = .integer16AttributeType
        } else if E.ValueType.self is NSNumber.Type {
            self = .doubleAttributeType
        } else if E.ValueType.self is String.Type {
            self = .stringAttributeType
        } else if E.ValueType.self is Date.Type {
            self = .dateAttributeType
        } else if E.ValueType.self is Data.Type {
            self = .binaryDataAttributeType
        } else {
            self = .undefinedAttributeType
        }
    }
}

internal extension _Expression {
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
    internal let builder: Builder<NSFetchRequest<NSDictionary>>
    
    private init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest<NSDictionary>>) {
        self.context = context
        self.builder = builder
    }
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest<NSDictionary>>, expressionDescription: @autoclosure(escaping) () -> NSExpressionDescription) {
        self.init(
            context: context,
            builder: builder.map {
                $0.resultType = .dictionaryResultType
                $0.propertiesToFetch = [expressionDescription()]
                return $0
            }
        )
    }
}

extension Aggregate: Executable {
    public typealias ElementType = NSDictionary
    
    public func fetchRequest() -> NSFetchRequest<NSDictionary> {
        let fetchRequest = self.builder.build()
        if Barrel.debugMode {
            print("NSFetchRequest generated: \(fetchRequest)")
        }
        return fetchRequest
    }
}

public extension Aggregate {
    func aggregate(_ expressionDescription: @autoclosure(escaping) () -> NSExpressionDescription) -> Aggregate {
        return Aggregate(
            context: context,
            builder: self.builder.map {
                $0.propertiesToFetch = $0.propertiesToFetch! + [expressionDescription()]
                return $0
            }
        )
    }
}

public extension Aggregate {
    func brl_aggregate<E: ExpressionType, V: ExpressionType where E.ValueType == V>(_ f: (Attribute<T>) -> E) -> Aggregate {
        return self.aggregate(unwrapExpression(f(Attribute())).expressionDescription())
    }
}

public extension Fetch {
    func aggregate(_ expressionDescription: @autoclosure(escaping) () -> NSExpressionDescription) -> Aggregate<T> {
        return Aggregate(
            context: context,
            builder: builder.map {
                let newRequest = NSFetchRequest<NSDictionary>(entityName: $0.entityName!)
                newRequest.predicate = $0.predicate
                newRequest.sortDescriptors = $0.sortDescriptors
                newRequest.fetchLimit = $0.fetchLimit
                newRequest.fetchOffset = $0.fetchOffset
                return newRequest
            },
            expressionDescription: expressionDescription
        )
    }
}

public extension Fetch {
    func brl_aggregate<E: ExpressionType, V: ExpressionType where E.ValueType == V>(_ f: (Attribute<T>) -> E) -> Aggregate<T> {
        return self.aggregate(unwrapExpression(f(Attribute())).expressionDescription())
    }
}
