//
//  SortDescriptor.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public struct SortDescriptors {
    public let value: [NSSortDescriptor]
    
    private init(_ value: [NSSortDescriptor]) {
        if Barrel.debugMode {
            print("Array of NSSortDescriptor generated: \(value)")
        }
        self.value = value
    }
    
    private init<T: Comparable, A: AttributeType where A.ValueType == T>(lhs: A, rhs: A, ascending: Bool) {
        if case .KEYPATH(let keyPath) = lhs.keyPath where !keyPath.containsString(".") {
            self.init([NSSortDescriptor(key: keyPath, ascending: ascending)])
        } else if case .KEYPATH(let keyPath) = rhs.keyPath where !keyPath.containsString(".") {
            self.init([NSSortDescriptor(key: keyPath, ascending: !ascending)])
        } else {
            self.init([])
        }
    }
    
    private init(lhs: SortDescriptors, rhs: SortDescriptors) {
        self.init(lhs.value + rhs.value)
    }
}

public func ><T: Comparable, A: AttributeType where A.ValueType == T>(lhs: A, rhs: A) -> SortDescriptors {
    return SortDescriptors(lhs: lhs, rhs: rhs, ascending: false)
}

public func <<T: Comparable, A: AttributeType where A.ValueType == T>(lhs: A, rhs: A) -> SortDescriptors {
    return SortDescriptors(lhs: lhs, rhs: rhs, ascending: true)
}

public func &(lhs: SortDescriptors, rhs: SortDescriptors) -> SortDescriptors {
    return SortDescriptors(lhs: lhs, rhs: rhs)
}