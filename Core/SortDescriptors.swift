//
//  SortDescriptor.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public struct _SortDescriptors {
    public let value: [SortDescriptor]
    
    private init(_ value: [SortDescriptor]) {
        if Barrel.debugMode {
            print("Array of NSSortDescriptor generated: \(value)")
        }
        self.value = value
    }
    
    private init<T: Comparable, A: AttributeType where A.ValueType == T>(lhs: A, rhs: A, ascending: Bool) {
        if case .keypath(let keyPath) = lhs.keyPath where !keyPath.contains(".") {
            self.init([SortDescriptor(key: keyPath, ascending: ascending)])
        } else if case .keypath(let keyPath) = rhs.keyPath where !keyPath.contains(".") {
            self.init([SortDescriptor(key: keyPath, ascending: !ascending)])
        } else {
            self.init([])
        }
    }
    
    private init(lhs: _SortDescriptors, rhs: _SortDescriptors) {
        self.init(lhs.value + rhs.value)
    }
}

public func ><T: Comparable, A: AttributeType where A.ValueType == T>(lhs: A, rhs: A) -> _SortDescriptors {
    return _SortDescriptors(lhs: lhs, rhs: rhs, ascending: false)
}

public func <<T: Comparable, A: AttributeType where A.ValueType == T>(lhs: A, rhs: A) -> _SortDescriptors {
    return _SortDescriptors(lhs: lhs, rhs: rhs, ascending: true)
}

public func &(lhs: _SortDescriptors, rhs: _SortDescriptors) -> _SortDescriptors {
    return _SortDescriptors(lhs: lhs, rhs: rhs)
}
