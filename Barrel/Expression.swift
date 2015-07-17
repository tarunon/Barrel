//
//  Expression.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

enum ExpressionFunctionType: String {
    case Add        = "add:to:"
    case Subtract   = "from:subtract:"
    case Multiply   = "multiply:by:"
    case Divide     = "divide:by:"
    case Max        = "max:"
    case Min        = "min:"
    case Sum        = "sum:"
    case Average    = "average:"
    case Count      = "count:"
        
    internal func name(s: [String]) -> String {
        return "_".join(map(zip(rawValue.componentsSeparatedByString(":"), s)) { $0.0 + "_" + $0.1 })
    }
    
    internal func name(x: String) -> String {
        return name([x])
    }
    
    internal func name(l: String)(_ r: String) -> String {
        return name([l, r])
    }
    
    internal func expression(s: [NSExpression]) -> NSExpression {
        return NSExpression(forFunction: rawValue, arguments: s)
    }
    
    internal func expression(x: NSExpression) -> NSExpression {
        return expression([x])
    }

    internal func expression(l: NSExpression)(_ r: NSExpression) -> NSExpression {
        return expression([l, r])
    }
}

public struct Expression<V: AttributeType>: AttributeType {
    typealias ValueType = V.ValueType
    internal let builder: Builder<NSExpression>
    internal let nameBuilder: Builder<String>

    private init(value: V?) {
        let attributeType = Attribute(value: value)
        switch attributeType {
        case .This:
            builder = Builder(NSExpression.expressionForEvaluatedObject())
            nameBuilder = Builder("self")
        case .KeyPath(let keyPath):
            builder = Builder(NSExpression(forKeyPath: keyPath))
            nameBuilder = Builder(keyPath)
        case .Value(let value):
            builder = Builder(NSExpression(forConstantValue: value))
            nameBuilder = Builder("\(value)")
        case .Null:
            // unsupported at swift 1.2
            builder = Builder(NSExpression(forConstantValue: NSNull()))
            nameBuilder = Builder("nil")
        case .Unsupported:
            // TODO: throw exception
            builder = Builder(NSExpression())
            nameBuilder = Builder("unsupported value")
        }
    }
    
    private init(lhs: Expression, rhs: Expression, type: ExpressionFunctionType) {
        builder = { l in { r in type.expression(l)(r) } }
            </> lhs.builder
            <*> rhs.builder
        nameBuilder = { l in { r in type.name(l)(r) } }
            </> lhs.nameBuilder
            <*> rhs.nameBuilder
    }
    
    private init(hs: Expression, type: ExpressionFunctionType) {
        builder = { type.expression($0) }
            </> hs.builder
        nameBuilder = { type.name($0) }
            </> hs.nameBuilder
    }
    
    static func createExpression<A: AttributeType where A.ValueType == V>(value: A?) -> Expression {
        if let expression = value as? Expression {
            return expression
        } else {
            return Expression(value: value as? V ?? unsafeBitCast(value, Optional.self))
        }
    }
    
    public func expression() -> NSExpression {
        return builder.build()
    }
    
    public func name() -> String {
        return nameBuilder.build()
    }
}

public func +<A1: AttributeType, A2: AttributeType where A1.ValueType == NSNumber, A2.ValueType == NSNumber>(lhs: A1?, rhs: A2?) -> Expression<NSNumber> {
    return Expression(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .Add)
}

public func -<A1: AttributeType, A2: AttributeType where A1.ValueType == NSNumber, A2.ValueType == NSNumber>(lhs: A1?, rhs: A2?) -> Expression<NSNumber> {
    return Expression(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .Subtract)
}

public func *<A1: AttributeType, A2: AttributeType where A1.ValueType == NSNumber, A2.ValueType == NSNumber>(lhs: A1?, rhs: A2?) -> Expression<NSNumber> {
    return Expression(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .Multiply)
}

public func /<A1: AttributeType, A2: AttributeType where A1.ValueType == NSNumber, A2.ValueType == NSNumber>(lhs: A1?, rhs: A2?) -> Expression<NSNumber> {
    return Expression(lhs: Expression.createExpression(lhs), rhs: Expression.createExpression(rhs), type: .Divide)
}

public func max<A: AttributeType where A.ValueType == NSNumber>(hs: A?) -> Expression<NSNumber> {
    return Expression(hs: Expression.createExpression(hs), type: .Max)
}

public func min<A: AttributeType where A.ValueType == NSNumber>(hs: A?) -> Expression<NSNumber> {
    return Expression(hs: Expression.createExpression(hs), type: .Min)
}

public func sum<A: AttributeType where A.ValueType == NSNumber>(hs: A?) -> Expression<NSNumber> {
    return Expression(hs: Expression.createExpression(hs), type: .Sum)
}

public func average<A: AttributeType where A.ValueType == NSNumber>(hs: A?) -> Expression<NSNumber> {
    return Expression(hs: Expression.createExpression(hs), type: .Average)
}

public func count<A: AttributeType>(hs: A?) -> Expression<A.ValueType> {
    return Expression(hs: Expression.createExpression(hs), type: .Count)
}
