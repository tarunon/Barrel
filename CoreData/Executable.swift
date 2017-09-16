//
//  Executable.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData

public protocol Executable: LazyCollectionProtocol {
    associatedtype ElementType: NSFetchRequestResult
    associatedtype Elements = [ElementType]
    associatedtype SubSequence = Array<ElementType>.SubSequence
    associatedtype Iterator = Array<ElementType>.Iterator

    var context: NSManagedObjectContext { get }
    func fetchRequest() -> NSFetchRequest<ElementType>
}

extension Executable {
    public func all() throws -> [ElementType] {
        return try self.context.fetch(self.fetchRequest())
    }
    
    public func get(_ offset: Int = 0) throws -> ElementType? {
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
    
    public subscript (position: Int) -> ElementType {
        return try! self.get(position)!
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public var elements: [ElementType] {
        return (try? all()) ?? []
    }

    public func makeIterator() -> Array<ElementType>.Iterator {
        return ((try? all()) ?? []).makeIterator()
    }
    
    public func underestimateCount() -> Int {
        do {
            return try self.count()
        } catch {
            return 0
        }
    }
    
    public func dropFirst(_ n: Int) -> ArraySlice<ElementType> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchOffset = n
            return ArraySlice(try self.context.fetch(fetchRequest))
        } catch {
            return []
        }
    }
    
    public func dropLast(_ n: Int) -> ArraySlice<ElementType> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchLimit = self.underestimateCount() - n
            return ArraySlice(try self.context.fetch(fetchRequest))
        } catch {
            return []
        }
    }
    
    public func prefix(_ maxLength: Int) -> ArraySlice<ElementType> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchLimit = maxLength
            return ArraySlice(try self.context.fetch(fetchRequest))
        } catch {
            return []
        }
    }
    
    public func suffix(_ maxLength: Int) -> ArraySlice<ElementType> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchOffset = self.underestimateCount() - maxLength
            return ArraySlice(try self.context.fetch(fetchRequest))
        } catch {
            return []
        }
    }

    public func split(maxSplits: Int, omittingEmptySubsequences: Bool, whereSeparator: (Self.ElementType) throws -> Bool) rethrows -> [AnySequence<Self.ElementType>] {
        do {
            return try self.all().split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: whereSeparator)
        } catch {
            return []
        }
    }
}
