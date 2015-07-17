//
//  Predicate.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

public enum PredicateCompoundType {
    case And
    case Or
    case Not
    
    func compound() -> NSCompoundPredicateType {
        switch self {
        case .And:
            return .AndPredicateType
        case .Or:
            return .OrPredicateType
        case .Not:
            return .NotPredicateType
        }
    }
    
    func predicate(s: [NSPredicate]) -> NSPredicate {
        return NSCompoundPredicate(type: compound(), subpredicates: s)
    }
    
    func predicate(x: NSPredicate) -> NSPredicate {
        return predicate([x])
    }
    
    func predicate(l: NSPredicate)(_ r: NSPredicate) -> NSPredicate {
        return predicate([l, r])
    }
}

public struct Predicate {
    internal let builder: Builder<NSPredicate>
    
    internal init() {
        self.builder = Builder(NSPredicate(value: true))
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
    init<A1: AttributeType, A2: AttributeType>(lhs: A1?, rhs: A2?, type: NSPredicateOperatorType, options: NSComparisonPredicateOptions) {
        builder = { l in { r in NSComparisonPredicate(leftExpression: l, rightExpression: r, modifier: .DirectPredicateModifier, type: type, options: options) } }
            </> Expression.createExpression(lhs).builder
            <*> Expression.createExpression(rhs).builder
    }
}

infix operator ~== { associativity none precedence 130 }

public func ==<A1: AttributeType, A2: AttributeType where A1.ValueType == String, A2.ValueType == String>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption | .DiacriticInsensitivePredicateOption)
}

public func ===<A1: AttributeType, A2: AttributeType where A1.ValueType == String, A2.ValueType == String>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .EqualToPredicateOperatorType, options: .allZeros)
}

public func ==<A1: AttributeType, A2: AttributeType, V: AttributeType where A1.ValueType == V, A2.ValueType == V>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .EqualToPredicateOperatorType, options: .allZeros)
}

public func !=<A1: AttributeType, A2: AttributeType where A1.ValueType == String, A2.ValueType == String>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .NotEqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption | .DiacriticInsensitivePredicateOption)
}

public func !==<A1: AttributeType, A2: AttributeType where A1.ValueType == String, A2.ValueType == String>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .NotEqualToPredicateOperatorType, options: .allZeros)
}

public func !=<A1: AttributeType, A2: AttributeType, V: AttributeType where A1.ValueType == V, A2.ValueType == V>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .NotEqualToPredicateOperatorType, options: .allZeros)
}

public func ~=<A1: AttributeType, A2: AttributeType where A1.ValueType == String, A2.ValueType == String>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .MatchesPredicateOperatorType, options: .CaseInsensitivePredicateOption | .DiacriticInsensitivePredicateOption)
}

public func ~==<A1: AttributeType, A2: AttributeType where A1.ValueType == String, A2.ValueType == String>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .MatchesPredicateOperatorType, options: .allZeros)
}

public func ><A1: AttributeType, A2: AttributeType, V: AttributeType where A1.ValueType == V, A2.ValueType == V>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .GreaterThanPredicateOperatorType, options: .allZeros)
}

public func >=<A1: AttributeType, A2: AttributeType, V: AttributeType where A1.ValueType == V, A2.ValueType == V>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .GreaterThanOrEqualToPredicateOperatorType, options: .allZeros)
}

public func <<A1: AttributeType, A2: AttributeType, V: AttributeType where A1.ValueType == V, A2.ValueType == V>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .LessThanPredicateOperatorType, options: .allZeros)
}

public func <=<A1: AttributeType, A2: AttributeType, V: AttributeType where A1.ValueType == V, A2.ValueType == V>(lhs: A1?, rhs: A2?) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .LessThanOrEqualToPredicateOperatorType, options: .allZeros)
}

public func <<<A: AttributeType, V: AttributeType where A.ValueType == V>(lhs: A?, rhs: [V]) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .InPredicateOperatorType, options: .allZeros)
}

public func <<<A: AttributeType where A.ValueType == NSNumber>(lhs: A?, rhs: Range<Int>) -> Predicate {
    return Predicate(lhs: lhs, rhs: [NSNumber(integer: rhs.startIndex), NSNumber(integer: rhs.endIndex)], type: .BetweenPredicateOperatorType, options: .allZeros)
}

public func >><T: NSManagedObject>(lhs: Set<T>, rhs: T) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .ContainsPredicateOperatorType, options: .allZeros)
}

public func >>(lhs: NSSet, rhs: NSManagedObject) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .ContainsPredicateOperatorType, options: .allZeros)
}

// MARK: logical operation
private extension Predicate {
    init(lhs: Predicate, rhs: Predicate, type: PredicateCompoundType) {
        builder = { l in { r in type.predicate(l)(r) } }
            </> lhs.builder
            <*> rhs.builder
    }
    
    init(hs: Predicate, type: PredicateCompoundType) {
        builder = { type.predicate($0) }
            </> hs.builder
    }
}

public func &&(lhs: Predicate, rhs: Predicate) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .And)
}

public func ||(lhs: Predicate, rhs: Predicate) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .Or)
}

public prefix func !(rhs: Predicate) -> Predicate {
    return Predicate(hs: rhs, type: .Not)
}
