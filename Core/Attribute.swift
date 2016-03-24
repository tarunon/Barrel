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
    return AttributeStorage.sharedInstance.attribute(name, parent: Optional<T>.None)
}

public func storedAttribute<T: AttributeType, U : AttributeType>(name: String = #function, parent: U) -> T {
    return AttributeStorage.sharedInstance.attribute(name, parent: parent)
}

private class AttributeStorage {
    var storage: [String: Any] = [:]
    
    static let sharedInstance = AttributeStorage()
    
    func attributeName<T: AttributeType>(attribute: T?) -> String? {
        guard let attribute = attribute else {
            return nil
        }
        switch attribute.keyPath {
        case .SELF:
            return nil
        case .KEYPATH(let keyPath):
            return keyPath
        }
    }
    
    func attribute<T: AttributeType, U: AttributeType>(name: String?, parent: T?) -> U {
        let key: String
        let parentName = self.attributeName(parent)
        if let name = name {
            if let parentName = parentName {
                key = "\(parentName).\(name).\(U.self)"
            } else {
                key = "\(name).\(U.self)"
            }
        } else {
            key = "\(U.self)"
        }
        if let attribute = self.storage[key] as? U {
            return attribute
        } else {
            let attribute = U(name: name, parent: parent)
            self.storage[key] = attribute
            return attribute
        }
    }
}