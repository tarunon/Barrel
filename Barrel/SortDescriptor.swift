//
//  SortDescriptor.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation

internal typealias SortDescriptorBuilder = () -> NSSortDescriptor

public struct SortDescriptor: Builder {
    internal let builder: SortDescriptorBuilder
    private init<T>(lhs: T?, rhs: T?, ascending: Bool) {
        if case .KeyPath(let keyPath) = AttributeType(value: lhs) {
            builder = { NSSortDescriptor(key: keyPath, ascending: ascending) }
        } else if case .KeyPath(let keyPath) = AttributeType(value: rhs) {
            builder = { NSSortDescriptor(key: keyPath, ascending: !ascending) }
        } else {
            builder = { NSSortDescriptor() }
        }
    }
}

extension SortDescriptor: Builder {
    public func build() -> NSSortDescriptor {
        return builder()
    }
    
    public func sortDescriptor() -> NSSortDescriptor {
        return builder()
    }
}

public func ><T>(lhs: T?, rhs: T?) -> SortDescriptor {
    return SortDescriptor(lhs: lhs, rhs: rhs, ascending: false)
}

public func <<T>(lhs: T?, rhs: T?) -> SortDescriptor {
    return SortDescriptor(lhs: lhs, rhs: rhs, ascending: true)
}
