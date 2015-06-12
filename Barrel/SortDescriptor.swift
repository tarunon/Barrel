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
    private init<T>(lhs: T, rhs: T, ascending: Bool) {
        builder = { () -> NSSortDescriptor in
            if let string = unwrapImplicitOptional(lhs) as? String, let attribute = string.decodingAttribute() {
                return NSSortDescriptor(key: attribute.keyPath, ascending: ascending)
            } else if let string = unwrapImplicitOptional(rhs) as? String, let attribute = string.decodingAttribute() {
                return NSSortDescriptor(key: attribute.keyPath, ascending: !ascending)
            }
            return NSSortDescriptor()
        }
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

public func ><T>(lhs: T, rhs: T) -> SortDescriptor {
    return SortDescriptor(lhs: lhs, rhs: rhs, ascending: false)
}

public func <<T>(lhs: T, rhs: T) -> SortDescriptor {
    return SortDescriptor(lhs: lhs, rhs: rhs, ascending: true)
}
