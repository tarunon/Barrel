//
//  Predicate.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

public struct Predicate {
    internal let builder: Builder<NSPredicate>
    
    internal init() {
        self.builder = Builder{ NSPredicate(value: true) }
    }
    
    private init(builder: Builder<NSPredicate>) {
        self.builder = builder
    }
    
    public func predicate() -> NSPredicate {
        return builder.build()
    }
}

// MARK: compariison operation
private extension Predicate {
    init<E1: ExpressionType, E2: ExpressionType>(lhs: E1?, rhs: E2?, type: NSPredicateOperatorType, options: NSComparisonPredicateOptions) {
        builder = Builder { NSComparisonPredicate(leftExpression: Expression.createExpression(lhs).expression(), rightExpression: Expression.createExpression(rhs).expression(), modifier: .DirectPredicateModifier, type: type, options: options) }
    }
}

infix operator ~== { associativity none precedence 130 }

public func ==<E1: ExpressionType, E2: ExpressionType where E1.ValueType == String, E2.ValueType == String>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption | .DiacriticInsensitivePredicateOption)
}

public func ===<E1: ExpressionType, E2: ExpressionType where E1.ValueType == String, E2.ValueType == String>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .EqualToPredicateOperatorType, options: .allZeros)
}

public func ==<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .EqualToPredicateOperatorType, options: .allZeros)
}

public func !=<E1: ExpressionType, E2: ExpressionType where E1.ValueType == String, E2.ValueType == String>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .NotEqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption | .DiacriticInsensitivePredicateOption)
}

public func !==<E1: ExpressionType, E2: ExpressionType where E1.ValueType == String, E2.ValueType == String>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .NotEqualToPredicateOperatorType, options: .allZeros)
}

public func !=<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .NotEqualToPredicateOperatorType, options: .allZeros)
}

public func ~=<E1: ExpressionType, E2: ExpressionType where E1.ValueType == String, E2.ValueType == String>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .MatchesPredicateOperatorType, options: .CaseInsensitivePredicateOption | .DiacriticInsensitivePredicateOption)
}

public func ~==<E1: ExpressionType, E2: ExpressionType where E1.ValueType == String, E2.ValueType == String>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .MatchesPredicateOperatorType, options: .allZeros)
}

public func ><E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .GreaterThanPredicateOperatorType, options: .allZeros)
}

public func >=<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .GreaterThanOrEqualToPredicateOperatorType, options: .allZeros)
}

public func <<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .LessThanPredicateOperatorType, options: .allZeros)
}

public func <=<E1: ExpressionType, E2: ExpressionType, V: ExpressionType where E1.ValueType == V, E2.ValueType == V>(lhs: E1?, rhs: E2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .LessThanOrEqualToPredicateOperatorType, options: .allZeros)
}

public func <<<E: ExpressionType, V: ExpressionType where E.ValueType == V>(lhs: E?, rhs: [V]) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .InPredicateOperatorType, options: .allZeros)
}

public func <<<E: ExpressionType where E.ValueType == NSNumber>(lhs: E?, rhs: Range<Int>) -> Predicate {
    return Predicate(lhs: lhs, rhs: [NSNumber(integer: rhs.startIndex), NSNumber(integer: rhs.endIndex)], type: .BetweenPredicateOperatorType, options: .allZeros)
}

public func >><E: NSManagedObject>(lhs: Set<E>, rhs: E) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .ContainsPredicateOperatorType, options: .allZeros)
}

public func >>(lhs: NSSet, rhs: NSManagedObject) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .ContainsPredicateOperatorType, options: .allZeros)
}

// MARK: logical operation
private extension Predicate {
    func and(other: Predicate) -> Predicate {
        return Predicate(builder: builder.map { NSCompoundPredicate(type: .AndPredicateType, subpredicates: [$0, other.predicate()]) })
    }
    
    func or(other: Predicate) -> Predicate {
        return Predicate(builder: builder.map { NSCompoundPredicate(type: .OrPredicateType, subpredicates: [$0, other.predicate()]) })
    }
    
    func not() -> Predicate {
        return Predicate(builder: builder.map { NSCompoundPredicate(type: .NotPredicateType, subpredicates: [$0]) })
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
