//
//  Expression.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

private typealias ExpressionBuilder = () -> NSExpression

public protocol ExpressionType {
    typealias ValueType: ExpressionType
}

extension NSObject: ExpressionType {
    typealias ValueType = NSObject
}

extension String: ExpressionType {
    typealias ValueType = String
}

extension Set: ExpressionType {
    typealias ValueType = Set
}

public struct Expression<V: ExpressionType>: ExpressionType {
    typealias ValueType = V.ValueType
    private let builder: ExpressionBuilder

    private init(value: V?) {
        let attributeType = Attribute(value: value)
        switch attributeType {
        case .KeyPath(let keyPath):
            builder = { NSExpression(forKeyPath: keyPath) }
        case .Value(let value):
            builder = { NSExpression(forConstantValue: value) }
        case .Null:
            // unsupported at swift 1.2
            builder = { NSExpression(forConstantValue: NSNull()) }
        case .Unsupported:
            // TODO: throw exception
            builder = { NSExpression() }
        }
    }
    
    private init(builder: ExpressionBuilder) {
        self.builder = builder
    }
    
    static func createExpression<E: ExpressionType where E.ValueType == V>(value: E?) -> Expression {
        if let expression = value as? Expression {
            return expression
        } else {
            return Expression(value: value as? V)
        }
    }
}

extension Expression: Builder {
    func build() -> NSExpression {
        return builder()
    }
    
    public func expression() -> NSExpression {
        return build()
    }
}
