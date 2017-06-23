//
//  KeyPath.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public indirect enum AttributeName {
    case `self`
    case keypath(String)
    case subKeypath(String, AttributeName)
    
    internal init(_ name: String?, parent: AttributeName?) {
        guard let name = name else {
            self = .self
            return
        }
        guard let parent = parent, parent != .self else {
            self = .keypath(name)
            return
        }
        self = .subKeypath(name, parent)
    }
    
    public var string: String {
        switch self {
        case .self:
            return "self"
        case .keypath(let keyPath):
            return keyPath
        case .subKeypath(let keyPath, let parent):
            return parent.string + "." + keyPath
        }
    }
}

extension AttributeName: Equatable {
    public static func == (lhs: AttributeName, rhs: AttributeName) -> Bool {
        switch (lhs, rhs) {
        case (.self, .self):
            return true
        case (.keypath(let lKeypath), .keypath(let rKeypath)):
            return lKeypath == rKeypath
        case (.subKeypath(let lKeypath, let lParent), .subKeypath(let rKeypath, let rParent)):
            return lKeypath == rKeypath && lParent == rParent
        default:
            return false
        }
    }
}
