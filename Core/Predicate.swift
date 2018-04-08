//
//  NSPredicate.swift
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
    
    typealias Generator = (NSComparisonPredicate.Modifier) -> NSComparisonPredicate
    let generator: Generator
    let modifier: NSComparisonPredicate.Modifier
    
    fileprivate init(generator: @escaping Generator, modifier: NSComparisonPredicate.Modifier) {
        self.generator = generator
        self.modifier = modifier
    }
}

extension ComparisonPredicate {
    init<L : ExpressionType, R : ExpressionType>(lhs: L, rhs: R, type: NSComparisonPredicate.Operator, options: NSComparisonPredicate.Options) where L.ValueType == R.ValueType {
        self.init(
            generator: {
                NSComparisonPredicate(leftExpression: Expression(lhs).value, rightExpression: Expression(rhs).value, modifier: $0, type: type, options: options)
            },
            modifier: .direct
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

public func ==<L: ExpressionType, R: ExpressionType>(lhs: L, rhs: R) -> ComparisonPredicate where L.ValueType == R.ValueType {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .equalTo, options: [])
}

public func <=<L: ExpressionType, R: ExpressionType>(lhs: L, rhs: R) -> ComparisonPredicate where L.ValueType == R.ValueType {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .lessThanOrEqualTo, options: [])
}

public func <<L: ExpressionType, R: ExpressionType>(lhs: L, rhs: R) -> ComparisonPredicate where L.ValueType == R.ValueType {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .lessThan, options: [])
}

public func >=<L: ExpressionType, R: ExpressionType>(lhs: L, rhs: R) -> ComparisonPredicate where L.ValueType == R.ValueType {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .greaterThanOrEqualTo, options: [])
}

public func ><L: ExpressionType, R: ExpressionType>(lhs: L, rhs: R) -> ComparisonPredicate where L.ValueType == R.ValueType {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .greaterThan, options: [])
}

public func !=<L: ExpressionType, R: ExpressionType>(lhs: L, rhs: R) -> ComparisonPredicate where L.ValueType == R.ValueType {
    return ComparisonPredicate(lhs: lhs, rhs: rhs, type: .notEqualTo, options: [])
}

public func <<<E: ExpressionType>(lhs: E, rhs: Range<E.ValueType>) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: Values([rhs.lowerBound, rhs.upperBound]), type: .between, options: [])
}

public func <<<E: ExpressionType>(lhs: E, rhs: [E.ValueType]) -> ComparisonPredicate {
    return ComparisonPredicate(lhs: lhs, rhs: Values(rhs), type: .in, options: [])
}

public struct CompoundPredicate: Predicate {
    public let value: NSPredicate
    
    init(predicate: NSPredicate) {
        value = predicate
    }
    
    init(lhs: Predicate, rhs: Predicate, type: NSCompoundPredicate.LogicalType) {
        self.init(predicate: NSCompoundPredicate(type: type, subpredicates: [lhs.value, rhs.value]))
    }
    
    init(hs: Predicate, type: NSCompoundPredicate.LogicalType) {
        self.init(predicate: NSCompoundPredicate(type: type, subpredicates: [hs.value]))
    }
}

public func &&(lhs: Predicate, rhs: Predicate) -> Predicate {
    return CompoundPredicate(lhs: lhs, rhs: rhs, type: .and)
}

public func ||(lhs: Predicate, rhs: Predicate) -> Predicate {
    return CompoundPredicate(lhs: lhs, rhs: rhs, type: .or)
}

public prefix func !(hs: Predicate) -> Predicate {
    return CompoundPredicate(hs: hs, type: .not)
}

extension AttributeType where ValueType == String {
    public func contains<E: ExpressionType>(_ other: E) -> ComparisonPredicate where E.ValueType == String {
        return ComparisonPredicate(lhs: self, rhs: other, type: .contains, options: [])
    }
    
    public func beginsWith<E: ExpressionType>(_ other: E) -> ComparisonPredicate where E.ValueType == String {
        return ComparisonPredicate(lhs: self, rhs: other, type: .beginsWith, options: [])
    }
    
    public func endsWith<E: ExpressionType>(_ other: E) -> ComparisonPredicate where E.ValueType == String {
        return ComparisonPredicate(lhs: self, rhs: other, type: .endsWith, options: [])
    }
    
    public func like<E: ExpressionType>(_ other: E) -> ComparisonPredicate where E.ValueType == String {
        return ComparisonPredicate(lhs: self, rhs: other, type: .like, options: [])
    }
    
    public func matches<E: ExpressionType>(_ other: E) -> ComparisonPredicate where E.ValueType == String {
        return ComparisonPredicate(lhs: self, rhs: other, type: .matches, options: [])
    }
}

public protocol ManyType: ExpressionType {
    associatedtype _ElementType: ExpressionType
}

extension AttributeType where SourceType: ManyType {
    public func any(_ f: (Attribute<SourceType._ElementType>) -> ComparisonPredicate) -> Predicate {
        return ComparisonPredicate(generator: f(Attribute(name:self.keyPath.string)).generator, modifier: .any)
    }
    
    public func all(_ f: (Attribute<SourceType._ElementType>) -> ComparisonPredicate) -> Predicate {
        return ComparisonPredicate(generator: f(Attribute(name:self.keyPath.string)).generator, modifier: .all)
    }
}

extension AttributeType where SourceType == Optional<ValueType> {
    public func isNull() -> ComparisonPredicate {
        return ComparisonPredicate(lhs: Expression(self), rhs: Expression<ValueType>(NSExpression(forConstantValue: nil)), type: .equalTo, options: [])
    }
    
    public func isNotNull() -> ComparisonPredicate {
        return ComparisonPredicate(lhs: Expression(self), rhs: Expression<ValueType>(NSExpression(forConstantValue: nil)), type: .notEqualTo, options: [])
    }
}

