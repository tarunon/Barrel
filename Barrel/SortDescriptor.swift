//
//  SortDescriptor.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation

public struct SortDescriptor {
    internal let builder: Builder<NSSortDescriptor>
    private init<T: AttributeType>(lhs: T?, rhs: T?, ascending: Bool) {
        switch Attribute(value: lhs) {
        case .KeyPath(let keyPath):
            builder = Builder { NSSortDescriptor(key: keyPath, ascending: ascending) }
            return
        default:
            break
        }
        switch Attribute(value: rhs) {
        case .KeyPath(let keyPath):
            builder = Builder { NSSortDescriptor(key: keyPath, ascending: !ascending) }
            return
        default:
            break
        }
        builder = Builder { NSSortDescriptor() }
    }
    
    public func sortDescriptor() -> NSSortDescriptor {
        return builder.build()
    }
}

public func ><T: AttributeType>(lhs: T?, rhs: T?) -> SortDescriptor {
    return SortDescriptor(lhs: lhs, rhs: rhs, ascending: false)
}

public func <<T: AttributeType>(lhs: T?, rhs: T?) -> SortDescriptor {
    return SortDescriptor(lhs: lhs, rhs: rhs, ascending: true)
}
