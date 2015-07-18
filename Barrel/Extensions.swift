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
    typealias ValueType = NSNumber
}

extension NSDate: AttributeType {
    typealias ValueType = NSDate
}

extension NSData: AttributeType {
    typealias ValueType = NSData
}

extension String: AttributeType {
    typealias ValueType = String
}

extension NSSet: AttributeType {
    typealias ValueType = NSSet
}

extension NSManagedObject: AttributeType {
    typealias ValueType = NSManagedObject
}

extension Set: AttributeType {
    typealias ValueType = NSSet
}

extension Array: AttributeType {
    typealias ValueType = Array
}
