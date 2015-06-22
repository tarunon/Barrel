//
//  Expression.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

internal typealias ExpressionBuilder = () -> NSExpression
internal typealias NameBuilder = () -> String

public protocol ExpressionType {
    typealias ValueType: ExpressionType
}

extension NSNumber: ExpressionType {
    typealias ValueType = NSNumber
}

extension NSDate: ExpressionType {
    typealias ValueType = NSDate
}

extension NSData: ExpressionType {
    typealias ValueType = NSData
}

extension String: ExpressionType {
    typealias ValueType = String
}

extension NSSet: ExpressionType {
    typealias ValueType = NSSet
}

extension NSManagedObject: ExpressionType {
    typealias ValueType = NSManagedObject
}

extension Set: ExpressionType {
    typealias ValueType = Set
}

internal extension NSAttributeType {
    init<E: ExpressionType>(type: E.Type) {
        if let _ = E.ValueType.self as? NSNumber.Type {
            self = .DoubleAttributeType
        } else if let _ = E.ValueType.self as? String.Type {
            self = .StringAttributeType
        } else if let _ = E.ValueType.self as? NSDate.Type {
            self = .DateAttributeType
        } else if let _ = E.ValueType.self as? NSData.Type {
            self = .BinaryDataAttributeType
        } else {
            self = .UndefinedAttributeType
        }
    }
}

enum ExpressionFunctionType {
    case Add
    case Subtract
    case Multiply
    case Divide
    case Max
    case Min
    case Sum
    case Average
    case Count
    
    internal func function() -> String {
        switch self {
        case .Add:
            return "add:to:"
        case .Subtract:
            return "from:subtract:"
        case .Multiply:
            return "multiply:by:"
        case .Divide:
            return "divide:by:"
        case .Max:
            return "max:"
        case .Min:
            return "min:"
        case .Count:
            return "count:"
        case .Sum:
            return "sum:"
        case .Average:
            return "average:"
        }
    }
    
    internal func name<T>(expressions: [Expression<T>]) -> String {
        return "_".join(Array(zip(function().componentsSeparatedByString(":"), expressions))
            .map{ $0.0 + "_" + $0.1.name() })
    }
}

public struct Expression<V: ExpressionType>: Builder, ExpressionType {
    typealias ValueType = V.ValueType
    internal let builder: ExpressionBuilder
    internal let nameBuilder: NameBuilder

    private init(value: V?) {
        let attributeType = Attribute(value: value)
        switch attributeType {
        case .This:
            builder = { NSExpression.expressionForEvaluatedObject() }
            nameBuilder = { "self" }
        case .KeyPath(let keyPath):
            builder = { NSExpression(forKeyPath: keyPath) }
            nameBuilder = { keyPath }
        case .Value(let value):
            builder = { NSExpression(forConstantValue: value) }
            nameBuilder = { "\(value)" }
        case .Null:
            builder = { NSExpression(forConstantValue: nil) }
            nameBuilder = { "nil" }
        case .Unsupported:
            // TODO: throw exception
            builder = { NSExpression() }
            nameBuilder = { "unsupported value" }
        }
    }
    
    private init(lhs: Expression, rhs: Expression, type: ExpressionFunctionType) {
        builder = { NSExpression(forFunction: type.function(), arguments: [lhs.expression(), rhs.expression()]) }
        nameBuilder = { type.name([lhs, rhs]) }
    }
    
    private init(hs: Expression, type: ExpressionFunctionType) {
        builder = { NSExpression(forFunction: type.function(), arguments: [hs.expression()]) }
        nameBuilder = { type.name([hs]) }
    }
    
    static func createExpression<E: ExpressionType where E.ValueType == V>(value: E?) -> Expression {
        if let expression = value as? Expression {
            return expression
        } else {
            return Expression(value: value as? V ?? unsafeBitCast(value, Optional.self))
        }
    }
    
    public func expression() -> NSExpression {
        return builder()
    }
    
    public func name() -> String {
        return nameBuilder()
    }
}

public func +<E1: ExpressionType, E2: ExpressionType where E1.ValueType == NSNumber, E2.ValueType == NSNumber>(lhs: E1?, rhs: E2?) -> Expression<NSNumber> {
    return Expression(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .Add)
}

public func -<E1: ExpressionType, E2: ExpressionType where E1.ValueType == NSNumber, E2.ValueType == NSNumber>(lhs: E1?, rhs: E2?) -> Expression<NSNumber> {
    return Expression(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .Subtract)
}

public func *<E1: ExpressionType, E2: ExpressionType where E1.ValueType == NSNumber, E2.ValueType == NSNumber>(lhs: E1?, rhs: E2?) -> Expression<NSNumber> {
    return Expression(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .Multiply)
}

public func /<E1: ExpressionType, E2: ExpressionType where E1.ValueType == NSNumber, E2.ValueType == NSNumber>(lhs: E1?, rhs: E2?) -> Expression<NSNumber> {
    return Expression(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .Divide)
}

public func max<E: ExpressionType where E.ValueType == NSNumber>(hs: E?) -> Expression<NSNumber> {
    return Expression(hs: Expression.createExpression(hs), type: .Max)
}

public func min<E: ExpressionType where E.ValueType == NSNumber>(hs: E?) -> Expression<NSNumber> {
    return Expression(hs: Expression.createExpression(hs), type: .Min)
}

public func sum<E: ExpressionType where E.ValueType == NSNumber>(hs: E?) -> Expression<NSNumber> {
    return Expression(hs: Expression.createExpression(hs), type: .Sum)
}

public func average<E: ExpressionType where E.ValueType == NSNumber>(hs: E?) -> Expression<NSNumber> {
    return Expression(hs: Expression.createExpression(hs), type: .Average)
}

public func count<E: ExpressionType, V: ExpressionType where E.ValueType == V>(hs: E?) -> Expression<V> {
    return Expression(hs: Expression.createExpression(hs), type: .Count)
}
