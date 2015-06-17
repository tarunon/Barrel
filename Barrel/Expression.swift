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


public struct Expression<T>: Builder {
    internal let builder: ExpressionBuilder

    internal init(value: T?) {
        let attributeType = AttributeType(value: value)
        switch attributeType {
        case .KeyPath(let keyPath):
            builder = { NSExpression(forKeyPath: keyPath) }
        case .Value(let value):
            builder = { NSExpression(forConstantValue: value) }
        case .Null:
            builder = { NSExpression(forConstantValue: nil) }
        case .Unsupported:
            // TODO: throw exception
            builder = { NSExpression() }
        }
    }
    
    private init(builder: ExpressionBuilder) {
        self.builder = builder
    }
}

extension Expression: Builder {
    public func build() -> NSExpression {
        return builder()
    }
    
    public func expression() -> NSExpression {
        return builder()
    }
}

