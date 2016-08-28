//
//  SortDescriptor.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public typealias SortDescriptor = NSSortDescriptor

public struct _SortDescriptors {
    public let value: [SortDescriptor]
    
    private init(_ value: [SortDescriptor]) {
        if Barrel.debugMode {
            print("Array of NSSortDescriptor generated: \(value)")
        }
        self.value = value
    }
    
    fileprivate init<T: Comparable, A: AttributeType>(lhs: A, rhs: A, ascending: Bool) where A.ValueType == T {
        if case .keypath(let keyPath) = lhs.keyPath, !keyPath.contains(".") {
            self.init([SortDescriptor(key: keyPath, ascending: ascending)])
        } else if case .keypath(let keyPath) = rhs.keyPath, !keyPath.contains(".") {
            self.init([SortDescriptor(key: keyPath, ascending: !ascending)])
        } else {
            self.init([])
        }
    }
    
    fileprivate init(lhs: _SortDescriptors, rhs: _SortDescriptors) {
        self.init(lhs.value + rhs.value)
    }
}

public func ><T: Comparable, A: AttributeType>(lhs: A, rhs: A) -> _SortDescriptors where A.ValueType == T {
    return _SortDescriptors(lhs: lhs, rhs: rhs, ascending: false)
}

public func <<T: Comparable, A: AttributeType>(lhs: A, rhs: A) -> _SortDescriptors where A.ValueType == T {
    return _SortDescriptors(lhs: lhs, rhs: rhs, ascending: true)
}

public func &(lhs: _SortDescriptors, rhs: _SortDescriptors) -> _SortDescriptors {
    return _SortDescriptors(lhs: lhs, rhs: rhs)
}
