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
        do {
            let result = try context.executeFetchRequest(build())
            return result.map{ $0 as! Type }
        } catch let error {
            throw error
        }
    }
    
    func get() throws -> Type? {
        do {
            let fetchRequest = build()
            fetchRequest.fetchLimit = 1
            return try context.executeFetchRequest(fetchRequest).first as? Type
        } catch let error {
            throw error
        }
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
