//
//  Group.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData
import Barrel

public struct Group<T: NSManagedObject where T: ExpressionType> {
    public let context: NSManagedObjectContext
    internal let builder: Builder<NSFetchRequest>
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>) {
        self.context = context
        self.builder = builder
    }
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>, @autoclosure(escaping) keyPath: () -> KeyPath) {
        self.init(context: context, builder: {
            $0.propertiesToGroupBy = [keyPath().string]
            $0.havingPredicate = NSPredicate(value: true)
            return $0
        } </> builder)
    }
}

extension Group {
    public func count() throws -> Int {
        return try self.context.executeFetchRequest(self.fetchRequest()).count
    }
    
    public func underestimateCount() -> Int {
        do {
            return try self.count()
        } catch {
            return 0
        }
    }
}

extension Group: Executable {
    public typealias Type = [String: AnyObject]
    
    public func fetchRequest() -> NSFetchRequest {
        let fetchRequest = self.builder.build()
        if Barrel.debugMode {
            print("NSFetchRequest generated: \(fetchRequest)")
        }
        return fetchRequest
    }
}

public extension Group {
    func groupBy(@autoclosure(escaping) keyPath: () -> KeyPath) -> Group {
        return Group(context: self.context, builder: {
            $0.propertiesToGroupBy = $0.propertiesToGroupBy! + [keyPath().string]
            return $0
        } </> self.builder)
    }
    
    func having(@autoclosure(escaping) predicate: () -> NSPredicate) -> Group {
        return Group(context: self.context, builder: {
            $0.havingPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [$0.havingPredicate!, predicate()])
            return $0
        } </> self.builder)
    }
}

public extension Group {
    func brl_groupBy<E: ExpressionType>(f: Attribute<T> -> Attribute<E>) -> Group {
        return self.groupBy(f(Attribute()).keyPath)
    }
    
    func brl_having(f: Attribute<T> -> Predicate) -> Group {
        return self.having(f(Attribute()).value)
    }
}

public extension Aggregate {
    func groupBy(@autoclosure(escaping) keyPath: () -> KeyPath) -> Group<T> {
        return Group(context: self.context, builder: self.builder, keyPath: keyPath)
    }
}

public extension Aggregate {
    func brl_groupBy<E: ExpressionType>(f: Attribute<T> -> Attribute<E>) -> Group<T> {
        return self.groupBy(f(Attribute()).keyPath)
    }
}
