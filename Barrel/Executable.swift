//
//  Executable.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

public protocol Executable: Builder {
    typealias Type
    var context: NSManagedObjectContext { get }
    func build() -> NSFetchRequest
}

public extension Executable {
    func all() throws -> [Type] {
        let result: [AnyObject]
        do {
            result = try context.executeFetchRequest(build())
        } catch let error {
            result = []
            throw error
        }
        return result.map({ $0 as! Type })
    }
    
    func get() throws -> Type? {
        let result: [AnyObject]
        do {
            let fetchRequest = build()
            fetchRequest.fetchLimit = 1
            result = try context.executeFetchRequest(fetchRequest)
        } catch let error {
            result = []
            throw error
        }
        return result.first as? Type
    }
    
    func count() throws -> Int {
        var error: NSError?
        let count = context.countForFetchRequest(build(), error: &error)
        if let error = error {
            throw error
        }
        return count
    }
}
