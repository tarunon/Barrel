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
    case Add        = "add:to:"
    case Subtract   = "from:subtract:"
    case Multiply   = "multiply:by:"
    case Divide     = "divide:by:"
    case Max        = "max:"
    case Min        = "min:"
    case Sum        = "sum:"
    case Average    = "average:"
    case Count      = "count:"
    
    func expression(s: [NSExpression]) -> NSExpression {
        return NSExpression(forFunction: self.rawValue, arguments: s)
    }
}

public struct Expression<T: ExpressionType>: ExpressionType {
    public typealias ValueType = T.ValueType
    public let value: NSExpression
    
    internal init(_ value: NSExpression) {
        if Barrel.debugMode {
            print("NSExpression generated: \(value)")
        }
        self.value = value
    }

    internal init<E: ExpressionType where E.ValueType == T>(_ value: E) {
        if let keyPath = Mirror(reflecting: value).descendant("keyPath") as? KeyPath {
            self.init(NSExpression(forKeyPath: keyPath.string))
        } else if let expression = value as? Expression<T> {
            self.init(expression.value)
        } else if let list = value as? Values<T> {
            self.init(NSExpression(forConstantValue: list.value as? AnyObject))
        } else {
            self.init(NSExpression(forConstantValue: value as? AnyObject))
        }
    }
    
    private init<L: ExpressionType, R: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R, function: ExpressionFunction) {
        self.init(function.expression([Expression(lhs).value, Expression(rhs).value]))
    }
    
    private init<E: ExpressionType where E.ValueType == T>(hs: E, function: ExpressionFunction) {
        self.init(function.expression([Expression<T>(hs).value]))
    }
}

public func unwrapExpression<E: ExpressionType, T: ExpressionType where E.ValueType == T>(value: E) -> Expression<T> {
    return Expression(value)
}

public func +<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> Expression<T> {
    return Expression(lhs: lhs, rhs: rhs, function: .Add)
}

public func -<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> Expression<T> {
    return Expression(lhs: lhs, rhs: rhs, function: .Subtract)
}

public func *<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> Expression<T> {
    return Expression(lhs: lhs, rhs: rhs, function: .Multiply)
}

public func /<L: ExpressionType, R: ExpressionType, T: ExpressionType where L.ValueType == T, R.ValueType == T>(lhs: L, rhs: R) -> Expression<T> {
    return Expression(lhs: lhs, rhs: rhs, function: .Divide)
}

extension AttributeType where ValueType: Comparable, ValueType: ExpressionType {
    public func max() -> Expression<ValueType> {
        return Expression(hs: self, function: .Max)
    }
    
    public func min() -> Expression<ValueType> {
        return Expression(hs: self, function: .Min)
    }
}

extension AttributeType where ValueType: NumberType, ValueType: ExpressionType {
    public func sum() -> Expression<ValueType> {
        return Expression(hs: self, function: .Sum)
    }

    public func average() -> Expression<ValueType> {
        return Expression(hs: self, function: .Average)
    }
}

extension AttributeType where ValueType: ExpressionType {
    public func count() -> Expression<Int> {
        return Expression(Expression(hs: self, function: .Count).value)
    }
}
