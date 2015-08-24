//
//  Extensions.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/07/18.
//  Copyright © 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

extension NSDate: Comparable {
    
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqualToDate(rhs)
}

public func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) != .OrderedDescending
}

public func >=(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) != .OrderedAscending
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

extension NSNumber: Comparable {
    
}

public func ==(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.isEqualToNumber(rhs)
}

public func <=(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) != .OrderedDescending
}

public func >=(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) != .OrderedAscending
}

public func <(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public func >(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

extension NSNumber: AttributeType {
    public typealias ValueType = NSNumber
}

extension NSDate: AttributeType {
    public typealias ValueType = NSDate
}

extension NSData: AttributeType {
    public typealias ValueType = NSData
}

extension String: AttributeType {
    public typealias ValueType = String
}

extension NSSet: AttributeType {
    public typealias ValueType = NSSet
}

extension NSManagedObject: AttributeType {
    public typealias ValueType = NSManagedObject
}

extension Set: AttributeType {
    public typealias ValueType = NSSet
}

extension Array: AttributeType {
    public typealias ValueType = Array
}
