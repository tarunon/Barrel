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
    init<A: AttributeType>(name: String?, parent: A?)
}

public extension AttributeType {
    func attribute<T: ExpressionType>(name: String = #function) -> Attribute<T> {
        return storedAttribute(name, parent: self)
    }
}

public struct Attribute<T: ExpressionType>: AttributeType {
    public typealias SourceType = T
    
    public let keyPath: KeyPath
    
    @available(*, unavailable)
    public init<A: AttributeType>(name: String?, parent: A?) {
        self.keyPath = KeyPath(name, parent: parent?.keyPath)
    }
}

extension Optional: ExpressionType {
    public typealias ValueType = Wrapped
}

public func storedAttribute<T: AttributeType>(name: String? = nil) -> T {
    return T(name: name, parent: Optional<T>.None)
}

public func storedAttribute<T: AttributeType, U : AttributeType>(name: String = #function, parent: U) -> T {
    return T(name: name, parent: parent)
}
