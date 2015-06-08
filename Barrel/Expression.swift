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
    internal init(value: T) {
        if let attribute = value as? ManagedObjectAttribute {
            builder = { NSExpression(forKeyPath: "self") }
        } else if let string = value as? String, let attribute = string.decodingAttribute() {
            builder = { NSExpression(forKeyPath: attribute.keyPath) }
        } else if let value: AnyObject = value as? AnyObject {
            builder = { NSExpression(forConstantValue: value) }
        } else {
            // exception
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
