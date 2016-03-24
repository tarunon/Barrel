//
//  Predicate.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public protocol Predicate {
    var value: NSPredicate { get }
}

public struct ComparisonPredicate: Predicate {
    public var value: NSPredicate {
        return generator(modifier)
    }
    
    typealias Generator = NSComparisonPredicateModifier -> NSComparisonPredicate
    let generator: Generator
    let modifier: NSComparisonPredicateModifier
    
    private init(generator: Generator, modifier: NSComparisonPredicateModifier) {
        if Barrel.debugMode {
            print("NSPredicate generated: \(generator(modifier))")
        }
        self.generator = generator
        self.modifier = modifier
    }
}

extension ComparisonPredicate {
    init<L : ExpressionType, R : ExpressionType, T : ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R, type: NSPredicateOperatorType, options: NSComparisonPredicateOptions) {
        self.init(
            generator: {
                NSComparisonPredicate(leftExpression: Expression(lhs).value, rightExpression: Expression(rhs).value, modifier: $0, type: type, options: options)
            },
            modifier: .DirectPredicateModifier
        )
    }
}

internal struct Values<E: ExpressionType>: ExpressionType {
    typealias ValueType = E
    let value: [E]
    init(_ value: [E]) {
        self.value = value
    }
}

public func ==<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .EqualToPredicateOperatorType, options: [])
}

public func <=<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .LessThanOrEqualToPredicateOperatorType, options: [])
}

public func <<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .LessThanPredicateOperatorType, options: [])
}

public func >=<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .GreaterThanOrEqualToPredicateOperatorType, options: [])
}

public func ><L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .GreaterThanPredicateOperatorType, options: [])
}

public func !=<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .NotEqualToPredicateOperatorType, options: [])
}

public func <<<E: ExpressionType, T: ExpressionType where E.ValueType == T>(lhs: E, rhs: Range<T>) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: Values([rhs.startIndex, rhs.endIndex]), type: .BetweenPredicateOperatorType, options: [])
}

public func <<<E: ExpressionType, T: ExpressionType where E.ValueType == T>(lhs: E, rhs: [T]) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: Values(rhs), type: .InPredicateOperatorType, options: [])
}

public struct CompoundPredicate: Predicate {
    public let value: NSPredicate
    
    init(predicate: NSPredicate) {
        if Barrel.debugMode {
            print("NSPredicate generated: \(predicate)")
        }
        value = predicate
    }
    
    init(lhs: Predicate, rhs: Predicate, type: NSCompoundPredicateType) {
        self.init(predicate: NSCompoundPredicate(type: type, subpredicates: [lhs.value, rhs.value]))
    }
    
    init(hs: Predicate, type: NSCompoundPredicateType) {
        self.init(predicate: NSCompoundPredicate(type: type, subpredicates: [hs.value]))
    }
}

public func &&(lhs: Predicate, rhs: Predicate) -> Predicate {
    return CompoundPredicate(lhs: lhs, rhs: rhs, type: .AndPredicateType)
}

public func ||(lhs: Predicate, rhs: Predicate) -> Predicate {
    return CompoundPredicate(lhs: lhs, rhs: rhs, type: .OrPredicateType)
}

public prefix func !(hs: Predicate) -> Predicate {
    return CompoundPredicate(hs: hs, type: .NotPredicateType)
}

extension AttributeType where ValueType == String {
    public func contains<E: ExpressionType where E.ValueType == String>(other: E) -> ComparisonPredicate {
        return ComparisonPredicate(lhs: self, rhs: other, type: .ContainsPredicateOperatorType, options: [])
    }
    
    public func beginsWith<E: ExpressionType where E.ValueType == String>(other: E) -> ComparisonPredicate {
        return ComparisonPredicate(lhs: self, rhs: other, type: .BeginsWithPredicateOperatorType, options: [])
    }
    
    public func endsWith<E: ExpressionType where E.ValueType == String>(other: E) -> ComparisonPredicate {
        return ComparisonPredicate(lhs: self, rhs: other, type: .EndsWithPredicateOperatorType, options: [])
    }
    
    public func like<E: ExpressionType where E.ValueType == String>(other: E) -> ComparisonPredicate {
        return ComparisonPredicate(lhs: self, rhs: other, type: .LikePredicateOperatorType, options: [])
    }
    
    public func matches<E: ExpressionType where E.ValueType == String>(other: E) -> ComparisonPredicate {
        return ComparisonPredicate(lhs: self, rhs: other, type: .MatchesPredicateOperatorType, options: [])
    }
}

public protocol ManyType: ExpressionType {
    associatedtype ElementType: ExpressionType
}

extension AttributeType where SourceType: ManyType {
    public func any(f: Attribute<SourceType.ElementType> -> ComparisonPredicate) -> Predicate {
        return ComparisonPredicate(generator: f(Attribute(name:self.keyPath.string)).generator, modifier: .AnyPredicateModifier)
    }
    
    public func all(f: Attribute<SourceType.ElementType> -> ComparisonPredicate) -> Predicate {
        return ComparisonPredicate(generator: f(Attribute(name:self.keyPath.string)).generator, modifier: .AllPredicateModifier)
    }
}

extension AttributeType where ValueType: ExpressionType, SourceType == Optional<ValueType> {
    public func isNull() -> ComparisonPredicate {
        return ComparisonPredicate(lhs: self, rhs: Expression<SourceType>(NSExpression(forConstantValue: nil)), type: .EqualToPredicateOperatorType, options: [])
    }
    
    public func isNotNull() -> ComparisonPredicate {
        return ComparisonPredicate(lhs: self, rhs: Expression<SourceType>(NSExpression(forConstantValue: nil)), type: .NotEqualToPredicateOperatorType, options: [])
    }
}

