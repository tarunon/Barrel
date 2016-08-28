//
//  Expression.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public protocol ExpressionType {
    associatedtype ValueType
}

enum ExpressionFunction: String {
    case add        = "add:to:"
    case subtract   = "from:subtract:"
    case multiply   = "multiply:by:"
    case divide     = "divide:by:"
    case max        = "max:"
    case min        = "min:"
    case sum        = "sum:"
    case average    = "average:"
    case count      = "count:"
    
    func expression(_ s: [NSExpression]) -> NSExpression {
        return NSExpression(forFunction: self.rawValue, arguments: s)
    }
}

public struct _Expression<T: ExpressionType>: ExpressionType {
    public typealias ValueType = T.ValueType
    public let value: NSExpression
    
    internal init(_ value: NSExpression) {
        if Barrel.debugMode {
            print("NSExpression generated: \(value)")
        }
        self.value = value
    }

    internal init<E: ExpressionType>(_ value: E) where E.ValueType == T {
        print(value)
        if let attribute = value as? AttributeBase {
            self.init(NSExpression(forKeyPath: attribute.keyPath.string))
        } else if let expression = value as? _Expression<T> {
            self.init(expression.value)
        } else if let list = value as? Values<T> {
            self.init(NSExpression(forConstantValue: list.value))
        } else {
            self.init(NSExpression(forConstantValue: value as? NSObject))
        }
    }
    
    fileprivate init<L: ExpressionType, R: ExpressionType>(lhs: L, rhs: R, function: ExpressionFunction) where L.ValueType == T, R.ValueType == T {
        self.init(function.expression([_Expression(lhs).value, _Expression(rhs).value]))
    }
    
    fileprivate init<E: ExpressionType>(hs: E, function: ExpressionFunction) where E.ValueType == T {
        self.init(function.expression([_Expression<T>(hs).value]))
    }
}

public func unwrapExpression<E: ExpressionType, T: ExpressionType>(_ value: E) -> _Expression<T> where E.ValueType == T {
    return _Expression(value)
}

public func +<L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _Expression<T> where L.ValueType == T, R.ValueType == T {
    return _Expression(lhs: lhs, rhs: rhs, function: .add)
}

public func -<L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _Expression<T> where L.ValueType == T, R.ValueType == T {
    return _Expression(lhs: lhs, rhs: rhs, function: .subtract)
}

public func *<L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _Expression<T> where L.ValueType == T, R.ValueType == T {
    return _Expression(lhs: lhs, rhs: rhs, function: .multiply)
}

public func /<L: ExpressionType, R: ExpressionType, T: ExpressionType>(lhs: L, rhs: R) -> _Expression<T> where L.ValueType == T, R.ValueType == T {
    return _Expression(lhs: lhs, rhs: rhs, function: .divide)
}

extension AttributeType where ValueType: Comparable, ValueType: ExpressionType {
    public func max() -> _Expression<ValueType> {
        return _Expression(hs: self, function: .max)
    }
    
    public func min() -> _Expression<ValueType> {
        return _Expression(hs: self, function: .min)
    }
}

extension AttributeType where ValueType: NumberType, ValueType: ExpressionType {
    public func sum() -> _Expression<ValueType> {
        return _Expression(hs: self, function: .sum)
    }

    public func average() -> _Expression<ValueType> {
        return _Expression(hs: self, function: .average)
    }
}

extension AttributeType where ValueType: ExpressionType {
    public func count() -> _Expression<Int> {
        return _Expression(_Expression(hs: self, function: .count).value)
    }
}
