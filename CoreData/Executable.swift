//
//  Executable.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData

public protocol Executable: Collection, Indexable {
    associatedtype ElementType: NSFetchRequestResult
    associatedtype FetchType: NSFetchRequestResult
    associatedtype GeneratorType = AnyIterator<ElementType>
    associatedtype SubSquence = ArraySlice<ElementType>
    associatedtype Index = Int
    var context: NSManagedObjectContext { get }
    func fetchRequest() -> NSFetchRequest<FetchType>
}

extension Executable {
    public func all() throws -> [ElementType] {
        return try self.context.fetch(self.fetchRequest()).map { $0 as! ElementType }
    }
    
    public func get(_ offset: Int = 0) throws -> ElementType? {
        let fetchRequest = self.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchOffset = offset
        return try self.context.fetch(fetchRequest).first as? ElementType
    }
    
    public func count() throws -> Int {
        return try self.context.count(for: self.fetchRequest())
    }
}

// Indexable
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
        return i
    }
}

// CollectionType
extension Executable {
    public func generate() -> AnyIterator<ElementType> {
        var count = 0
        return AnyIterator { () -> ElementType? in
            do {
                count += 1
                return try self.get(count)
            } catch {
                return nil
            }
        }
    }
    
    public func underestimateCount() -> Int {
        do {
            return try self.count()
        } catch {
            return 0
        }
    }

    public func map<T>(_ transform: (ElementType) throws -> T) rethrows -> [T] {
        do {
            return try self.all().map(transform)
        } catch {
            return []
        }
    }
    
    public func filter(_ includeElement: (ElementType) throws -> Bool) rethrows -> [ElementType] {
        do {
            return try self.all().filter(includeElement)
        } catch {
            return []
        }
    }
    
    public func forEach(_ body: (ElementType) throws -> ()) rethrows {
        do {
            return try self.all().forEach(body)
        } catch {
            
        }
    }
    
    public func dropFirst(_ n: Int) -> ArraySlice<ElementType> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchOffset = n
            return ArraySlice(try self.context.fetch(fetchRequest).map { $0 as! ElementType })
        } catch {
            return []
        }
    }
    
    public func dropLast(_ n: Int) -> ArraySlice<ElementType> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchLimit = self.underestimateCount() - n
            return ArraySlice(try self.context.fetch(fetchRequest).map { $0 as! ElementType })
        } catch {
            return []
        }
    }
    
    public func prefix(_ maxLength: Int) -> ArraySlice<ElementType> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchLimit = maxLength
            return ArraySlice(try self.context.fetch(fetchRequest).map { $0 as! ElementType })
        } catch {
            return []
        }
    }
    
    public func suffix(_ maxLength: Int) -> ArraySlice<ElementType> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchOffset = self.underestimateCount() - maxLength
            return ArraySlice(try self.context.fetch(fetchRequest).map { $0 as! ElementType })
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
