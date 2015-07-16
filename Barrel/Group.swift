//
//  Group.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/04.
//  Copyright (c) 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData

public struct Group<T: NSManagedObject> {
    public let context: NSManagedObjectContext
    internal let builder: Builder<NSFetchRequest>
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>, @autoclosure(escaping) keyPath: () -> String) {
        self.context = context
        self.builder = builder.map {
            $0.propertiesToGroupBy = [keyPath()]
            $0.havingPredicate = NSPredicate(value: true)
            return $0
        }
    }
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>) {
        self.context = context
        self.builder = builder
    }
    
    public func fetchRequest() -> NSFetchRequest {
        return builder.build()
    }
}

extension Group: Executable {
    typealias Type = [String: AnyObject]
}

// MARK: group methods
public extension Group {
    func groupBy(@autoclosure(escaping) keyPath: () -> String) -> Group {
        return Group(context: context, builder: builder.map {
            $0.propertiesToGroupBy = $0.propertiesToGroupBy! + [keyPath()]
            return $0
        })
    }
    func having(@autoclosure(escaping) predicate: () -> NSPredicate) -> Group {
        return Group(context: context, builder: builder.map {
            $0.havingPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [$0.havingPredicate!, predicate()])
            return $0
        })
    }
}

// MARK: group methods via attribute
public extension Group {
    public func having(predicate: (T -> Predicate)) -> Group {
        return having(predicate(self.context.attribute()).predicate())
    }
    
    public func groupBy<E: ExpressionType>(argument: (T) -> E) -> Group {
        return groupBy(Expression.createExpression(argument(self.context.attribute())).name())
    }
}
