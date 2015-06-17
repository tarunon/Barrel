//
//  Executable.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

public protocol Executable {
    typealias Type
    var context: NSManagedObjectContext { get }
}

public extension Executable where Self: Builder, Self.Result == NSFetchRequest {
    func all() throws -> [Type] {
        do {
            let result = try context.executeFetchRequest(builder())
            return result.map{ $0 as! Type }
        } catch let error {
            throw error
        }
    }
    
    func get() throws -> Type? {
        do {
            let fetchRequest = builder()
            fetchRequest.fetchLimit = 1
            return try context.executeFetchRequest(fetchRequest).first as? Type
        } catch let error {
            throw error
        }
    }
    
    func count() throws -> Int {
        var error: NSError?
        let count = context.countForFetchRequest(builder(), error: &error)
        if let error = error {
            throw error
        }
        return count
    }
}
