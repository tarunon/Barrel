//
//  Aggregate.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/24.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

public struct Aggregate<T: NSManagedObject> {
    internal let context: NSManagedObjectContext
    internal let builder: Builder<NSFetchRequest>
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>, @autoclosure(escaping) expressionDescription: () -> NSExpressionDescription) {
        self.context = context
        self.builder = builder.map {
            $0.resultType = .DictionaryResultType
            $0.propertiesToFetch = [expressionDescription()]
            return $0
        }
    }
    
    private init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>) {
        self.context = context
        self.builder = builder
    }

    public func fetchRequest() -> NSFetchRequest {
        return builder.build()
    }
}

extension Aggregate: Executable {
    public func execute() -> ExecuteResult<[String: AnyObject]> {
        return _execute(self)
    }
    
    public func count() -> CountResult {
        return _count(self)
    }
}

// MARK: aggregate methods
public extension Aggregate {
    func aggregate(@autoclosure(escaping) expression: () -> NSExpressionDescription) -> Aggregate {
        return Aggregate(context: context, builder: builder.map {
            $0.propertiesToFetch = $0.propertiesToFetch! + [expression()]
            return $0
            })
    }
}

// MARK: to group
public extension Aggregate {
    func groupBy(@autoclosure(escaping) keyPath: () -> String) -> Group<T> {
        return Group(context: context, builder: builder, keyPath: keyPath)
    }
}

// MARK: aggregate methods via attribute
public extension Aggregate {
    public func aggregate<E: AttributeType>(expressionDescription: T -> E) -> Aggregate {
        return aggregate(ExpressionDescription(argument: Expression.createExpression(expressionDescription(self.context.attribute()))).expressionDescription())
    }
    
    public func groupBy<E: AttributeType>(argument: T -> E) -> Group<T> {
        return Group(context: context, builder: builder, keyPath: Expression.createExpression(argument(self.context.attribute())).name())
    }
}
