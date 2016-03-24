//
//  Fetch.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData
import Barrel

public struct Fetch<T: NSManagedObject where T: ExpressionType> {
    public let context: NSManagedObjectContext
    internal let builder: Builder<NSFetchRequest>
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>) {
        self.context = context
        self.builder = builder
    }
    
    internal init(context: NSManagedObjectContext) {
        self.init(context: context, builder: Builder {
            let fetchRequest = NSFetchRequest(entityName: context.entityName(T)!)
            fetchRequest.predicate = NSPredicate(value: true)
            fetchRequest.sortDescriptors = []
            return fetchRequest
        })
    }
}

extension Fetch: Executable {
    public typealias Type = T
    
    public func fetchRequest() -> NSFetchRequest {
        let fetchRequest = self.builder.build()
        if Barrel.debugMode {
            print("NSFetchRequest generated: \(fetchRequest)")
        }
        return fetchRequest
    }
    
    public func delete() {
        self.forEach { self.context.deleteObject($0) }
    }
}

public extension Fetch {
    public func filter(@autoclosure(escaping) predicate: () -> NSPredicate) -> Fetch {
        return Fetch(context: self.context, builder: {
            $0.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [$0.predicate!, predicate()])
            return $0
        } </> self.builder)
    }
    
    public func sorted(@autoclosure(escaping) sortDescriptor: () -> [NSSortDescriptor]) -> Fetch {
        return Fetch(context: self.context, builder: {
            $0.sortDescriptors = $0.sortDescriptors! + sortDescriptor()
            return $0
        } </> self.builder)
    }
    
    public func limit(limit: Int) -> Fetch {
        return Fetch(context: self.context, builder: {
            $0.fetchLimit = limit
            return $0
        } </> self.builder)
    }
    
    public func offset(offset: Int) -> Fetch {
        return Fetch(context: self.context, builder: {
            $0.fetchOffset = offset
            return $0
        } </> self.builder)
    }
}

public extension Fetch {
    public func brl_filter(f: Attribute<T> -> Predicate) -> Fetch {
        return self.filter(f(Attribute()).value)
    }
    
    public func brl_sorted(f: (Attribute<T>, Attribute<T>) -> SortDescriptors) -> Fetch {
        return self.sorted(f(Attribute(), Attribute(name: "sort")).value)
    }
}
