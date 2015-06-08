//
//  Executable.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

public enum ExecuteResult<T> {
    case Succeed([T])
    case Failed(NSError)
    
    public func all() -> [T] {
        switch self {
        case .Succeed(let value):
            return value
        default:
            return []
        }
    }
    
    public func get() -> T? {
        switch self {
        case .Succeed(let value):
            return value.first
        default:
            return nil
        }
    }
}

public enum CountResult {
    case Succeed(Int)
    case Failed(NSError)
    
    public func count() -> Int {
        switch self {
        case .Succeed(let value):
            return value
        default:
            return 0
        }
    }
}

internal protocol Executable: Builder {
    typealias T
    var context: NSManagedObjectContext { get }
    func build() -> NSFetchRequest
    func execute() -> ExecuteResult<T>
    func count() -> CountResult
}

internal func _execute<T, E: Executable where E.T == T>(executable: E) -> ExecuteResult<T> {
    var error: NSError?
    let result = executable.context.executeFetchRequest(executable.build(), error: &error)
    if let error = error {
        return .Failed(error)
    } else if let result = result?.map({ $0 as! T }) {
        return .Succeed(result)
    }
    return .Failed(NSError())
}

internal func _count<E: Executable>(executable: E) -> CountResult {
    var error: NSError?
    let result = executable.context.countForFetchRequest(executable.build(), error: &error)
    if let error = error {
        return .Failed(error)
    } else {
        return .Succeed(result)
    }
}