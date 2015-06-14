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


public struct Expression<T> {
    private let builder: ExpressionBuilder

    private static func unwrapManagedObjectSet<U>(value: T) -> Set<U>? {
        if let set = value as? Set<U> {
            return set
        }
        return nil
    }

    internal init(value: T?) {
        let attributeType = AttributeType(value: value)
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
}

extension Expression: Builder {
    func build() -> NSExpression {
        return builder()
    }
    
    public func expression() -> NSExpression {
        return build()
    }
}
