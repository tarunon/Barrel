//
//  Predicate.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

internal typealias PredicateBuilder = () -> NSPredicate

public struct Predicate: Builder {
    internal let builder: PredicateBuilder
    private init(builder: PredicateBuilder) {
        self.builder = builder
    }
    
    public func predicate() -> NSPredicate {
        return builder()
    }
}

// MARK: compariison operation
private extension Predicate {
    init<T, U>(lhs: Expression<T>, rhs: Expression<U>, type: NSPredicateOperatorType) {
        builder = { NSComparisonPredicate(leftExpression: lhs.expression(), rightExpression: rhs.expression(), modifier: .DirectPredicateModifier, type: type, options: []) }
    }
}

public func ==<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .EqualToPredicateOperatorType)
}

public func !=<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .NotEqualToPredicateOperatorType)
}

public func ~=<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .LikePredicateOperatorType)
}

public func ><E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .GreaterThanPredicateOperatorType)
}

public func >=<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .GreaterThanOrEqualToPredicateOperatorType)
}

public func <<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .LessThanPredicateOperatorType)
}

public func <=<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .LessThanOrEqualToPredicateOperatorType)
}

// MARK: logical operation
private extension Predicate {
    func and(other: Predicate) -> Predicate {
        return Predicate(builder: builder >>> { NSCompoundPredicate(type: .AndPredicateType, subpredicates: [$0, other.predicate()]) })
    }
    
    func or(other: Predicate) -> Predicate {
        return Predicate(builder: builder >>> { NSCompoundPredicate(type: .OrPredicateType, subpredicates: [$0, other.predicate()]) })
    }
    
    func not() -> Predicate {
        return Predicate(builder: builder >>> { NSCompoundPredicate(type: .NotPredicateType, subpredicates: [$0]) })
    }
}

public func &&(lhs: Predicate, rhs: Predicate) -> Predicate {
    return lhs.and(rhs)
}

public func ||(lhs: Predicate, rhs: Predicate) -> Predicate {
    return lhs.or(rhs)
}

public prefix func !(rhs: Predicate) -> Predicate {
    return rhs.not()
}
