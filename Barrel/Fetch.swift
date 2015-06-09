//
//  Fetch.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/24.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

internal typealias RequestBuilder = () -> NSFetchRequest

public struct Fetch<T: NSManagedObject> {
    public let context: NSManagedObjectContext
    internal let builder: RequestBuilder
    
    internal init(context: NSManagedObjectContext) {
        self.context = context
        builder = { () -> NSFetchRequest in
            let fetchRequest = NSFetchRequest(entityName: context.entityName(T)!)
            fetchRequest.predicate = NSPredicate(value: true)
            fetchRequest.sortDescriptors = []
            return fetchRequest
        }
    }
    
    private init(context: NSManagedObjectContext, builder: RequestBuilder) {
        self.context = context
        self.builder = builder
    }
}

extension Fetch: Builder {
    public func build() -> NSFetchRequest {
        return builder()
    }
    
    public func fetchRequest() -> NSFetchRequest {
        return build()
    }
}

extension Fetch: Executable {
    typealias Type = T
    public func delete() {
        try! all().map{ self.context.deleteObject($0) }
    }
}

// MARK: results controller
public extension Fetch {
    public func resultsController(sectionKeyPath sectionKeyPath: String?, cacheName: String?) -> ResultsController<T> {
        return ResultsController(fetchRequest: build(), context: context, sectionNameKeyPath: sectionKeyPath, cacheName: cacheName)
    }
}

// MARK: fetch methods
public extension Fetch {
    public func filter(@autoclosure(escaping) predicate: () -> NSPredicate) -> Fetch {
        return Fetch(context: context, builder: builder >>> { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [fetchRequest.predicate!, predicate()])
            return fetchRequest
            })
    }
    
    public func orderBy(@autoclosure(escaping) sortDescriptor: () -> NSSortDescriptor) -> Fetch {
        return Fetch(context: context, builder: builder >>> { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.sortDescriptors = fetchRequest.sortDescriptors! + [sortDescriptor()]
            return fetchRequest
            })
    }
    
    public func limit(limit: Int) -> Fetch {
        return Fetch(context: context, builder: builder >>> { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.fetchLimit = limit
            return fetchRequest
            })
    }
    
    public func offset(offset: Int) -> Fetch {
        return Fetch(context: context, builder: builder >>> { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.fetchOffset = offset
            return fetchRequest
            })
    }
}

// MARK: context support
public extension NSManagedObjectContext {
    public func fetch<T: NSManagedObject>() -> Fetch<T> {
        return Fetch(context: self)
    }
    
    public func fetch<T: NSManagedObject>(type: T.Type) -> Fetch<T> {
        return fetch()
    }
}

// MARK: to aggregate
public extension Fetch {
    public func aggregate(expressionDescription: NSExpressionDescription) -> Aggregate<T> {
        return Aggregate(context: context, builder: builder, expressionDescription: expressionDescription)
    }
}

// MARK: fetch methods via attribute
public extension Fetch {
    public func filter(predicate: (T -> Predicate)) -> Fetch {
        return filter(predicate(self.context.attribute(T)).build())
    }
    
    public func orderBy(sortDescriptor: ((T, T) -> SortDescriptor)) -> Fetch {
        return orderBy(sortDescriptor(self.context.attribute(T), self.context.comparison(T)).build())
    }
    
    public func aggregate(expressionDescription:(ExpressionDescription<T>, T) -> ExpressionDescription<T>) -> Aggregate<T> {
        return aggregate(expressionDescription(ExpressionDescription(context: context), self.context.attribute(T)).build())
    }
    
    public func aggregate<U>(expressionDescription:(ExpressionDescription<T>, T) -> U) -> Aggregate<T> {
        return aggregate({ () -> NSExpressionDescription in
            let description = ExpressionDescription<T>(context: self.context)
            let result = Expression(value: expressionDescription(description, self.context.attribute(T)))
            return description.keyPath(result).build()
        }())
    }
}
