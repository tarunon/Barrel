//
//  Executable.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData

public protocol Executable: CollectionType, Indexable {
    typealias Type
    typealias GeneratorType = AnyGenerator<Type>
    typealias SubSquence = ArraySlice<Type>
    typealias Index = Int
    var context: NSManagedObjectContext { get }
    func fetchRequest() -> NSFetchRequest
}

extension Executable {
    public func all() throws -> [Type] {
        return try self.context.executeFetchRequest(self.fetchRequest()).map { $0 as! Type }
    }
    
    public func get(offset: Int = 0) throws -> Type? {
        let fetchRequest = self.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchOffset = offset
        return try self.context.executeFetchRequest(fetchRequest).first as? Type
    }
    
    public func count() throws -> Int {
        var error: NSError?
        let count = self.context.countForFetchRequest(self.fetchRequest(), error: &error)
        if let error = error {
            throw error
        }
        return count
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
    
    public subscript (position: Int) -> Type {
        return try! self.get(position)!
    }
}

// CollectionType
extension Executable {
    public func generate() -> AnyGenerator<Type> {
        var count = 0
        return anyGenerator({ () -> Type? in
            do {
                return try self.get(count++)
            } catch {
                return nil
            }
        })
    }
    
    public func underestimateCount() -> Int {
        do {
            return try self.count()
        } catch {
            return 0
        }
    }
    
    public func map<T>(@noescape transform: (Type) throws -> T) rethrows -> [T] {
        do {
            return try self.all().map(transform)
        } catch {
            return []
        }
    }
    
    public func filter(@noescape includeElement: (Type) throws -> Bool) rethrows -> [Type] {
        do {
            return try self.all().filter(includeElement)
        } catch {
            return []
        }
    }
    
    public func forEach(@noescape body: (Type) throws -> ()) rethrows {
        do {
            return try self.all().forEach(body)
        } catch {
            
        }
    }
    
    public func dropFirst(n: Int) -> ArraySlice<Type> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchOffset = n
            return ArraySlice(try self.context.executeFetchRequest(fetchRequest).map { $0 as! Type })
        } catch {
            return []
        }
    }
    
    public func dropLast(n: Int) -> ArraySlice<Type> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchLimit = self.underestimateCount() - n
            return ArraySlice(try self.context.executeFetchRequest(fetchRequest).map { $0 as! Type })
        } catch {
            return []
        }
    }
    
    public func prefix(maxLength: Int) -> ArraySlice<Type> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchLimit = maxLength
            return ArraySlice(try self.context.executeFetchRequest(fetchRequest).map { $0 as! Type })
        } catch {
            return []
        }
    }
    
    public func suffix(maxLength: Int) -> ArraySlice<Type> {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.fetchOffset = self.underestimateCount() - maxLength
            return ArraySlice(try self.context.executeFetchRequest(fetchRequest).map { $0 as! Type })
        } catch {
            return []
        }
    }
    
    public func split(maxSplit: Int, allowEmptySlices: Bool, @noescape isSeparator: (Type) throws -> Bool) rethrows -> [ArraySlice<Type>] {
        do {
            return try self.all().split(maxSplit, allowEmptySlices: allowEmptySlices, isSeparator: isSeparator)
        } catch {
            return []
        }
    }
}