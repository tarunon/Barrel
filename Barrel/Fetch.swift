//
//  Fetch.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/24.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

public struct Fetch<T: NSManagedObject> {
    internal let context: NSManagedObjectContext
    internal let builder: Builder<NSFetchRequest>
    
    internal init(context: NSManagedObjectContext) {
        self.context = context
        builder = Builder { 
            let fetchRequest = NSFetchRequest(entityName: context.entityName(T)!)
            fetchRequest.predicate = Predicate().predicate()
            fetchRequest.sortDescriptors = []
            return fetchRequest
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

extension Fetch: Executable {
    public func execute() -> ExecuteResult<T> {
        return _execute(self)
    }
    
    public func count() -> CountResult {
        return _count(self)
    }
    
    public func delete() {
        execute().all().map({ self.context.delete($0) })
    }
}

// MARK: results controller
public extension Fetch {
    public func resultsController(#sectionKeyPath: String?, cacheName: String?) -> ResultsController<T> {
        return ResultsController(fetchRequest: fetchRequest(), context: context, sectionNameKeyPath: sectionKeyPath, cacheName: cacheName)
    }
}

// MARK: fetch methods
public extension Fetch {
    public func filter(@autoclosure(escaping) predicate: () -> NSPredicate) -> Fetch {
        return Fetch(context: context, builder: builder.map {
            $0.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [$0.predicate!, predicate()])
            return $0
        })
    }
    
    public func orderBy(@autoclosure(escaping) sortDescriptor: () -> NSSortDescriptor) -> Fetch {
        return Fetch(context: context, builder: builder.map {
            $0.sortDescriptors = $0.sortDescriptors! + [sortDescriptor()]
            return $0
        })
    }
    
    public func limit(limit: Int) -> Fetch {
        return Fetch(context: context, builder: builder.map {
            $0.fetchLimit = limit
            return $0
        })
    }
    
    public func offset(offset: Int) -> Fetch {
        return Fetch(context: context, builder: builder.map {
            $0.fetchOffset = offset
            return $0
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
    public func aggregate(@autoclosure(escaping) expressionDescription: () -> NSExpressionDescription) -> Aggregate<T> {
        return Aggregate(context: context, builder: builder, expressionDescription: expressionDescription())
    }
}

// MARK: fetch methods via attribute
public extension Fetch {
    public func filter(predicate: (T -> Predicate)) -> Fetch {
        return filter(predicate(self.context.attribute()).predicate())
    }
    
    public func orderBy(sortDescriptor: ((T, T) -> SortDescriptor)) -> Fetch {
        return orderBy(sortDescriptor(self.context.attribute(), self.context.comparison()).sortDescriptor())
    }
    
    public func aggregate<E: ExpressionType>(expressionDescription:(T) -> E) -> Aggregate<T> {
        return aggregate(ExpressionDescription(argument: Expression.createExpression(expressionDescription(self.context.attribute()))).expressionDescription())
    }
}
