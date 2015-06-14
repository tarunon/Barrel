//
//  SortDescriptor.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation

private typealias SortDescriptorBuilder = () -> NSSortDescriptor

public struct SortDescriptor {
    private let builder: SortDescriptorBuilder
    private init<T>(lhs: T?, rhs: T?, ascending: Bool) {
        switch AttributeType(value: lhs) {
        case .KeyPath(let keyPath):
            builder = { NSSortDescriptor(key: keyPath, ascending: ascending) }
            return
        default:
            break
        }
        switch AttributeType(value: rhs) {
        case .KeyPath(let keyPath):
            builder = { NSSortDescriptor(key: keyPath, ascending: !ascending) }
            return
        default:
            break
        }
        builder = { NSSortDescriptor() }
    }
}

extension SortDescriptor: Builder {
    func build() -> NSSortDescriptor {
        return builder()
    }
    
    public func sortDescriptor() -> NSSortDescriptor {
        return build()
    }
}

public func ><T>(lhs: T?, rhs: T?) -> SortDescriptor {
    return SortDescriptor(lhs: lhs, rhs: rhs, ascending: false)
}

public func <<T>(lhs: T?, rhs: T?) -> SortDescriptor {
    return SortDescriptor(lhs: lhs, rhs: rhs, ascending: true)
}
