//
//  KeyPath.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public enum KeyPath {
    case `self`
    case keypath(String)
    
    internal init(_ name: String?, parent: KeyPath?) {
        guard let name = name else {
            self = .`self`
            return
        }
        guard let parent = parent, case .keypath(let parentName) = parent else {
            self = .keypath(name)
            return
        }
        self = .keypath(parentName + "." + name)
    }
    
    public var string: String {
        switch self {
        case .`self`:
            return "self"
        case .keypath(let keyPath):
            return keyPath
        }
    }
}
