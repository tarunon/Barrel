//
//  Attribute.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public protocol AttributeBase {
    var keyPath: KeyPath { get }
}

public protocol AttributeType: ExpressionType, AttributeBase {
    associatedtype SourceType: ExpressionType
    associatedtype ValueType = SourceType.ValueType
}

public extension AttributeType {
    func attribute<T: ExpressionType>(_ name: String = #function) -> Attribute<T> {
        return Attribute(name: name, parent: self)
    }
}

public struct Attribute<T: ExpressionType>: AttributeType {
    public typealias SourceType = T
    
    public let keyPath: KeyPath
    
    public init(name: String? = nil) {
        self.keyPath = KeyPath(name, parent: nil)
    }
    
    public init<A: AttributeType>(name: String?, parent: A?) {
        self.keyPath = KeyPath(name, parent: parent?.keyPath)
    }
}

extension Optional: ExpressionType {
    public typealias ValueType = Wrapped
}

@available(*, unavailable, renamed : "Attribute")
public func storedAttribute<T: AttributeType>(_ name: String? = nil) -> T {
    fatalError()
}

@available(*, unavailable, renamed : "Attribute")
public func storedAttribute<T: AttributeType, U : AttributeType>(_ name: String = #function, parent: U) -> T {
    fatalError()
}
