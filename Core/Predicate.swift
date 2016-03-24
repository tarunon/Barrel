//
//  Predicate.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

extension NSCompoundPredicateType {
    func predicate(s: [NSPredicate]) -> NSPredicate {
        return NSCompoundPredicate(type: self, subpredicates: s)
    }
}

public protocol PredicateType {
    var value: NSPredicate { get }
    init<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R, type: NSPredicateOperatorType, options: NSComparisonPredicateOptions)
}

public struct Predicate: PredicateType {
    public let value: NSPredicate
    
    private init(_ value: NSPredicate) {
        if Barrel.debugMode {
            print("NSPredicate generated: \(value)")
        }
        self.value = value
    }
    
    @available(*, unavailable)
    public init<L : ExpressionType, R : ExpressionType, T : ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R, type: NSPredicateOperatorType, options: NSComparisonPredicateOptions) {
        self.init(NSComparisonPredicate(leftExpression: Expression(lhs).value, rightExpression: Expression(rhs).value, modifier: .DirectPredicateModifier, type: type, options: options))
    }
}

public struct AnyPredicate: PredicateType {
    public let value: NSPredicate
    
    private init(_ value: NSPredicate) {
        if Barrel.debugMode {
            print("NSPredicate generated: \(value)")
        }
        self.value = value
    }
    
    @available(*, unavailable)
    public init<L : ExpressionType, R : ExpressionType, T : ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R, type: NSPredicateOperatorType, options: NSComparisonPredicateOptions) {
        self.init(NSComparisonPredicate(leftExpression: Expression(lhs).value, rightExpression: Expression(rhs).value, modifier: .AnyPredicateModifier, type: type, options: options))
    }
}

public struct AllPredicate: PredicateType {
    public let value: NSPredicate
    
    private init(_ value: NSPredicate) {
        if Barrel.debugMode {
            print("NSPredicate generated: \(value)")
        }
        self.value = value
    }
    
    @available(*, unavailable)
    public init<L : ExpressionType, R : ExpressionType, T : ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R, type: NSPredicateOperatorType, options: NSComparisonPredicateOptions) {
        self.init(NSComparisonPredicate(leftExpression: Expression(lhs).value, rightExpression: Expression(rhs).value, modifier: .AllPredicateModifier, type: type, options: options))
    }
}

internal struct Values<E: ExpressionType>: ExpressionType {
    typealias ValueType = E
    let value: [E]
    init(_ value: [E]) {
        self.value = value
    }
}

public func ==<L: ExpressionType, R: ExpressionType, T: ExpressionType, P: PredicateType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> P {
    return P(lhs: lhs, rhs: rhs, type: .EqualToPredicateOperatorType, options: [])
}

public func <=<L: ExpressionType, R: ExpressionType, T: ExpressionType, P: PredicateType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> P {
    return P(lhs: lhs, rhs: rhs, type: .LessThanOrEqualToPredicateOperatorType, options: [])
}

public func <<L: ExpressionType, R: ExpressionType, T: ExpressionType, P: PredicateType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> P {
    return P(lhs: lhs, rhs: rhs, type: .LessThanPredicateOperatorType, options: [])
}

public func >=<L: ExpressionType, R: ExpressionType, T: ExpressionType, P: PredicateType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> P {
    return P(lhs: lhs, rhs: rhs, type: .GreaterThanOrEqualToPredicateOperatorType, options: [])
}

public func ><L: ExpressionType, R: ExpressionType, T: ExpressionType, P: PredicateType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> P {
    return P(lhs: lhs, rhs: rhs, type: .GreaterThanPredicateOperatorType, options: [])
}

public func !=<L: ExpressionType, R: ExpressionType, T: ExpressionType, P: PredicateType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> P {
    return P(lhs: lhs, rhs: rhs, type: .NotEqualToPredicateOperatorType, options: [])
}

public func <<<E: ExpressionType, T: ExpressionType, P: PredicateType where E.ValueType == T>(lhs: E, rhs: Range<T>) -> P {
    return P(lhs: lhs, rhs: Values([rhs.startIndex, rhs.endIndex]), type: .BetweenPredicateOperatorType, options: [])
}

public func <<<E: ExpressionType, T: ExpressionType, P: PredicateType where E.ValueType == T>(lhs: E, rhs: [T]) -> P {
    return P(lhs: lhs, rhs: Values(rhs), type: .InPredicateOperatorType, options: [])
}

private extension Predicate {
    init(lhs: PredicateType, rhs: PredicateType, type: NSCompoundPredicateType) {
        self.init(type.predicate([lhs.value, rhs.value]))
    }
    
    init(hs: PredicateType, type: NSCompoundPredicateType) {
        self.init(type.predicate([hs.value]))
    }
}

public func &&(lhs: PredicateType, rhs: PredicateType) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .AndPredicateType)
}

public func ||(lhs: PredicateType, rhs: PredicateType) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .OrPredicateType)
}

public prefix func !(hs: PredicateType) -> Predicate {
    return Predicate(hs: hs, type: .NotPredicateType)
}

extension AttributeType where ValueType == String {
    public func contains<E: ExpressionType, P: PredicateType where E.ValueType == String>(other: E) -> P {
        return P(lhs: self, rhs: other, type: .ContainsPredicateOperatorType, options: [])
    }
    
    public func beginsWith<E: ExpressionType, P: PredicateType where E.ValueType == String>(other: E) -> P {
        return P(lhs: self, rhs: other, type: .BeginsWithPredicateOperatorType, options: [])
    }
    
    public func endsWith<E: ExpressionType, P: PredicateType where E.ValueType == String>(other: E) -> P {
        return P(lhs: self, rhs: other, type: .EndsWithPredicateOperatorType, options: [])
    }
    
    public func like<E: ExpressionType, P: PredicateType where E.ValueType == String>(other: E) -> P {
        return P(lhs: self, rhs: other, type: .LikePredicateOperatorType, options: [])
    }
    
    public func matches<E: ExpressionType, P: PredicateType where E.ValueType == String>(other: E) -> P {
        return P(lhs: self, rhs: other, type: .MatchesPredicateOperatorType, options: [])
    }
}

public protocol ManyType: ExpressionType {
    associatedtype ElementType: ExpressionType
}

extension AttributeType where SourceType: ManyType {
    public func any(f: Attribute<SourceType.ElementType> -> AnyPredicate) -> Predicate {
        return Predicate(f(Attribute(name: self.keyPath.string)).value)
    }
    
    public func all(f: Attribute<SourceType.ElementType> -> AllPredicate) -> Predicate {
        return Predicate(f(Attribute(name: self.keyPath.string)).value)
    }
}

extension AttributeType where ValueType: ExpressionType, SourceType == Optional<ValueType> {
    public func isNull<P: PredicateType>() -> P {
        return P(lhs: self, rhs: Expression<SourceType>(NSExpression(forConstantValue: nil)), type: .EqualToPredicateOperatorType, options: [])
    }
    
    public func isNotNull<P: PredicateType>() -> P {
        return P(lhs: self, rhs: Expression<SourceType>(NSExpression(forConstantValue: nil)), type: .NotEqualToPredicateOperatorType, options: [])
    }
}

