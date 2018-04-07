//
//  Executable.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData
import Barrel

public protocol Executable: LazyCollectionProtocol where Element: NSFetchRequestResult, Elements == [Element] {
    var context: NSManagedObjectContext { get }
    func fetchRequest() -> NSFetchRequest<Element>
}

extension Executable {
    public func all() throws -> [Element] {
        return try self.context.fetch(self.fetchRequest())
    }
    
    public func get(_ offset: Int = 0) throws -> Element? {
        let fetchRequest = self.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchOffset = offset
        return try self.context.fetch(fetchRequest).first
    }
    
    public func count() throws -> Int {
        return try self.context.count(for: self.fetchRequest())
    }
}

extension Executable {
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        do {
            return try self.count()
        } catch {
            return 0
        }
    }
    
    public subscript (position: Int) -> Element {
        return try! self.get(position)!
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public var elements: [Element] {
        return (try? all()) ?? []
    }

    public func makeIterator() -> Elements.Iterator {
        return ((try? all()) ?? []).makeIterator()
    }
    
    public func underestimateCount() -> Int {
        do {
            return try self.count()
        } catch {
            return 0
        }
    }
}
