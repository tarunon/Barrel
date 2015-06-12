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
    public let context: NSManagedObjectContext
    internal let builder: RequestBuilder
    
    internal init(context: NSManagedObjectContext, builder: RequestBuilder, @autoclosure(escaping) expressionDescription: () -> NSExpressionDescription) {
        self.context = context
        self.builder = builder >>> { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.propertiesToFetch = [expressionDescription()]
            return fetchRequest
        }
    }
    
    private init(context: NSManagedObjectContext, builder: RequestBuilder) {
        self.context = context
        self.builder = builder
    }
}

extension Aggregate: Builder {
    public func build() -> NSFetchRequest {
        let fetchRequest = builder()
        fetchRequest.resultType = .DictionaryResultType
        return fetchRequest
    }
    
    public func fetchRequest() -> NSFetchRequest {
        return build()
    }
}

extension Aggregate: Executable {
    typealias Type = [String: AnyObject]
}

// MARK: aggregate methods
public extension Aggregate {
    func aggregate(@autoclosure(escaping) expression: () -> NSExpressionDescription) -> Aggregate {
        return Aggregate(context: context, builder: builder >>> { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
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
    public func aggregate(expressionDescription:(ExpressionDescription<T>, T) -> ExpressionDescription<T>) -> Aggregate {
        return aggregate(expressionDescription(ExpressionDescription(context: self.context), self.context.attribute()).build())
    }
    
    public func aggregate<U>(expressionDescription:(ExpressionDescription<T>, T) -> U) -> Aggregate {
        return aggregate({ () -> NSExpressionDescription in
            let description = ExpressionDescription<T>(context: self.context)
            let result = Expression(value: expressionDescription(description, self.context.attribute()))
            return description.keyPath(result).build()
            }())
    }
    
    public func groupBy<U>(keyPath: (T) -> U) -> Group<T> {
        return Group(context: context, builder: builder, keyPath: {
            if let attribute = (keyPath(self.context.attribute()) as? String)?.decodingProperty() {
                return attribute.keyPath
            }
            return ""
        }())
    }
    
    public func groupBy<U>(keyPath: (T) -> Expression<U>) -> Group<T> {
        return Group(context: context, builder: builder, keyPath: keyPath(self.context.attribute()).build().keyPath)
    }
}
