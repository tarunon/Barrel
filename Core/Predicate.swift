//
//  Predicate.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public typealias Predicate = NSPredicate
public typealias ComparisonPredicate = NSComparisonPredicate
public typealias CompoundPredicate = NSCompoundPredicate

public protocol _Predicate {
    var value: Predicate { get }
}

public struct _ComparisonPredicate: _Predicate {
    public var value: Predicate {
        return generator(modifier)
    }
    
    typealias Generator = (ComparisonPredicate.Modifier) -> ComparisonPredicate
    let generator: Generator
    let modifier: ComparisonPredicate.Modifier
    
    fileprivate init(generator: Generator, modifier: ComparisonPredicate.Modifier) {
        if Barrel.debugMode {
            print("NSPredicate generated: \(generator(modifier))")
        }
        self.generator = generator
        self.modifier = modifier
    }
}

extension _ComparisonPredicate {
    init<L : ExpressionType, R : ExpressionType, T : ExpressionType>(lhs: L, rhs: R, type: ComparisonPredicate.Operator, options: ComparisonPredicate.Options) where L.ValueType == T, R.ValueType == T {
        self.init(
            generator: {
                ComparisonPredicate(leftExpression: _Expression(lhs).value, rightExpression: _Expression(rhs).value, modifier: $0, type: type, options: options)
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

public func ==<L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _ComparisonPredicate where L.ValueType == T, R.ValueType == T {
    return _ComparisonPredicate(lhs: lhs, rhs: rhs, type: .equalTo, options: [])
}

public func <=<L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _ComparisonPredicate where L.ValueType == T, R.ValueType == T {
    return _ComparisonPredicate(lhs: lhs, rhs: rhs, type: .lessThanOrEqualTo, options: [])
}

public func <<L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _ComparisonPredicate where L.ValueType == T, R.ValueType == T {
    return _ComparisonPredicate(lhs: lhs, rhs: rhs, type: .lessThan, options: [])
}

public func >=<L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _ComparisonPredicate where L.ValueType == T, R.ValueType == T {
    return _ComparisonPredicate(lhs: lhs, rhs: rhs, type: .greaterThanOrEqualTo, options: [])
}

public func ><L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _ComparisonPredicate where L.ValueType == T, R.ValueType == T {
    return _ComparisonPredicate(lhs: lhs, rhs: rhs, type: .greaterThan, options: [])
}

public func !=<L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _ComparisonPredicate where L.ValueType == T, R.ValueType == T {
    return _ComparisonPredicate(lhs: lhs, rhs: rhs, type: .notEqualTo, options: [])
}

public func <<<E: ExpressionType, T: ExpressionType>(lhs: E, rhs: Range<T>) -> _ComparisonPredicate where E.ValueType == T {
    return _ComparisonPredicate(lhs: lhs, rhs: Values([rhs.lowerBound, rhs.upperBound]), type: .between, options: [])
}

public func <<<E: ExpressionType, T: ExpressionType>(lhs: E, rhs: [T]) -> _ComparisonPredicate where E.ValueType == T {
    return _ComparisonPredicate(lhs: lhs, rhs: Values(rhs), type: .in, options: [])
}

public struct _CompoundPredicate: _Predicate {
    public let value: Predicate
    
    init(predicate: Predicate) {
        if Barrel.debugMode {
            print("NSPredicate generated: \(predicate)")
        }
        value = predicate
    }
    
    init(lhs: _Predicate, rhs: _Predicate, type: CompoundPredicate.LogicalType) {
        self.init(predicate: CompoundPredicate(type: type, subpredicates: [lhs.value, rhs.value]))
    }
    
    init(hs: _Predicate, type: CompoundPredicate.LogicalType) {
        self.init(predicate: CompoundPredicate(type: type, subpredicates: [hs.value]))
    }
}

public func &&(lhs: _Predicate, rhs: _Predicate) -> _Predicate {
    return _CompoundPredicate(lhs: lhs, rhs: rhs, type: .and)
}

public func ||(lhs: _Predicate, rhs: _Predicate) -> _Predicate {
    return _CompoundPredicate(lhs: lhs, rhs: rhs, type: .or)
}

public prefix func !(hs: _Predicate) -> _Predicate {
    return _CompoundPredicate(hs: hs, type: .not)
}

extension AttributeType where ValueType == String {
    public func contains<E: ExpressionType>(_ other: E) -> _ComparisonPredicate where E.ValueType == String {
        return _ComparisonPredicate(lhs: self, rhs: other, type: .contains, options: [])
    }
    
    public func beginsWith<E: ExpressionType>(_ other: E) -> _ComparisonPredicate where E.ValueType == String {
        return _ComparisonPredicate(lhs: self, rhs: other, type: .beginsWith, options: [])
    }
    
    public func endsWith<E: ExpressionType>(_ other: E) -> _ComparisonPredicate where E.ValueType == String {
        return _ComparisonPredicate(lhs: self, rhs: other, type: .endsWith, options: [])
    }
    
    public func like<E: ExpressionType>(_ other: E) -> _ComparisonPredicate where E.ValueType == String {
        return _ComparisonPredicate(lhs: self, rhs: other, type: .like, options: [])
    }
    
    public func matches<E: ExpressionType>(_ other: E) -> _ComparisonPredicate where E.ValueType == String {
        return _ComparisonPredicate(lhs: self, rhs: other, type: .matches, options: [])
    }
}

public protocol ManyType: ExpressionType {
    associatedtype ElementType: ExpressionType
}

extension AttributeType where SourceType: ManyType {
    public func any(_ f: (Attribute<SourceType.ElementType>) -> _ComparisonPredicate) -> _Predicate {
        return _ComparisonPredicate(generator: f(Attribute(name:self.keyPath.string)).generator, modifier: .any)
    }
    
    public func all(_ f: (Attribute<SourceType.ElementType>) -> _ComparisonPredicate) -> _Predicate {
        return _ComparisonPredicate(generator: f(Attribute(name:self.keyPath.string)).generator, modifier: .all)
    }
}

extension AttributeType where ValueType: ExpressionType, SourceType == Optional<ValueType> {
    public func isNull() -> _ComparisonPredicate {
        return _ComparisonPredicate(lhs: self, rhs: _Expression<SourceType>(NSExpression(forConstantValue: nil)), type: .equalTo, options: [])
    }
    
    public func isNotNull() -> _ComparisonPredicate {
        return _ComparisonPredicate(lhs: self, rhs: _Expression<SourceType>(NSExpression(forConstantValue: nil)), type: .notEqualTo, options: [])
    }
}

