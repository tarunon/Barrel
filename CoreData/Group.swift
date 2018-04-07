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

public struct Group<T: NSManagedObject> {
    public let context: NSManagedObjectContext
    internal let builder: Builder<NSFetchRequest<NSDictionary>>
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest<NSDictionary>>) {
        self.context = context
        self.builder = builder
    }
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest<NSDictionary>>, keyPath: @autoclosure @escaping () -> AttributeName) {
        self.init(
            context: context,
            builder: builder.map {
                $0.propertiesToGroupBy = [keyPath().string]
                $0.havingPredicate = NSPredicate(value: true)
                return $0
            }
        )
    }
}

extension Group {
    public func count() throws -> Int {
        return try self.context.fetch(self.fetchRequest()).count
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
    public typealias Element = NSDictionary
    
    public func fetchRequest() -> NSFetchRequest<NSDictionary> {
        let fetchRequest = self.builder.build()
        return fetchRequest
    }
}

public extension Group {
    func groupBy(_ keyPath: @autoclosure @escaping () -> AttributeName) -> Group {
        return Group(
            context: self.context,
            builder: self.builder.map {
                $0.propertiesToGroupBy = $0.propertiesToGroupBy! + [keyPath().string]
                return $0
            }
        )
    }
    
    func having(_ predicate: @autoclosure @escaping () -> NSPredicate) -> Group {
        return Group(
            context: self.context,
            builder: self.builder.map {
                $0.havingPredicate = NSCompoundPredicate(type: .and, subpredicates: [$0.havingPredicate!, predicate()])
                return $0
            }
        )
    }
}

public extension Group {
    @available(*, renamed: "brl.groupBy")
    func brl_groupBy<E>(_ f: @escaping (Attribute<T>) -> Attribute<E>) -> Group {
        return self.groupBy(f(Attribute()).keyPath)
    }

    @available(*, renamed: "brl.having")
    func brl_having(_ f: @escaping (Attribute<T>) -> Predicate) -> Group {
        return self.having(f(Attribute()).value)
    }
}

public extension Aggregate {
    func groupBy(_ keyPath: @autoclosure @escaping () -> AttributeName) -> Group<T> {
        return Group(context: self.context, builder: self.builder, keyPath: keyPath)
    }
}

public extension Aggregate {
    @available(*, renamed: "brl.groupBy")
    func brl_groupBy<E>(_ f: @escaping (Attribute<T>) -> Attribute<E>) -> Group<T> {
        return self.groupBy(f(Attribute()).keyPath)
    }
}
