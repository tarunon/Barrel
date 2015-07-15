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
        self.builder = builder.map { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.resultType = .DictionaryResultType
            fetchRequest.propertiesToFetch = [expressionDescription()]
            return fetchRequest
        }
    }
    
    private init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>) {
        self.context = context
        self.builder = builder
    }
}

extension Aggregate {
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
        return Aggregate(context: context, builder: builder.map { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.propertiesToFetch = fetchRequest.propertiesToFetch! + [expression()]
            return fetchRequest
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
    public func aggregate<E: ExpressionType>(expressionDescription:(T) -> E) -> Aggregate {
        return aggregate({ () -> NSExpressionDescription in
            return ExpressionDescription(argument: Expression.createExpression(expressionDescription(self.context.attribute()))).expressionDescription()
            }())
    }
    
    public func groupBy<E: ExpressionType>(argument: (T) -> E) -> Group<T> {
        return Group(context: context, builder: builder, keyPath: Expression.createExpression(argument(self.context.attribute())).name())
    }
}
