//
//  Attribute.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public protocol AttributeType: ExpressionType {
    typealias FieldType
    var keyPath: KeyPath { get }
    init(name: String?, parentName: String?)
}

public struct Attribute<T: ExpressionType>: AttributeType {
    public typealias FieldType = T
    public typealias ValueType = T.ValueType
    
    public let keyPath: KeyPath
    
    @available(*, unavailable)
    public init(name: String?, parentName: String?) {
        self.keyPath = KeyPath(name, parentName: parentName)
    }
}

public struct OptionalAttribute<T: ExpressionType>: AttributeType {
    public typealias FieldType = T
    public typealias ValueType = T.ValueType
    
    public let keyPath: KeyPath
    
    @available(*, unavailable)
    public init(name: String? = nil, parentName: String? = nil) {
        self.keyPath = KeyPath(name, parentName: parentName)
    }
}

public func storedAttribute<T: AttributeType>(name: String? = nil) -> T {
    return AttributeStorage.sharedInstance.attribute(name, parent: Optional<T>.None)
}

public func storedAttribute<T: AttributeType, U : AttributeType>(name: String = __FUNCTION__, parent: U) -> T {
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
            let attribute = U(name: name, parentName: attributeName(parent))
            self.storage[key] = attribute
            return attribute
        }
    }
}