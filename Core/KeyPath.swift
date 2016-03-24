//
//  KeyPath.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public enum KeyPath {
    case SELF
    case KEYPATH(String)
    
    internal init(_ name: String?, parent: KeyPath?) {
        guard let name = name else {
            self = .SELF
            return
        }
        guard let parent = parent, case .KEYPATH(let parentName) = parent else {
            self = .KEYPATH(name)
            return
        }
        self = .KEYPATH(parentName + "." + name)
    }
    
    public var string: String {
        switch self {
        case .SELF:
            return "self"
        case .KEYPATH(let keyPath):
            return keyPath
        }
    }
}
