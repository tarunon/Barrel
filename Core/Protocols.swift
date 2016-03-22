//
//  Protocols.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public protocol NumberType {}

public protocol NSComparable: Comparable {
    func compare(other: Self) -> NSComparisonResult
}

public func <<C: NSComparable>(lhs: C, rhs: C) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public func <=<C: NSComparable>(lhs: C, rhs: C) -> Bool {
    return lhs.compare(rhs) != .OrderedDescending
}

public func >=<C: NSComparable>(lhs: C, rhs: C) -> Bool {
    return lhs.compare(rhs) != .OrderedAscending
}

public func ><C: NSComparable>(lhs: C, rhs: C) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

public protocol SelfExpression : ExpressionType {
    associatedtype ValueType = Self
}

extension Double : SelfExpression, NumberType {}

extension Int16 : SelfExpression, NumberType {}

extension Int32 : SelfExpression, NumberType {}

extension Int64 : SelfExpression, NumberType {}

extension Float : SelfExpression, NumberType {}

extension Bool : SelfExpression, NumberType {}

extension Int : SelfExpression , NumberType {
    public typealias ValueType = Int
}

extension NSDate : SelfExpression, NSComparable {}

extension String : SelfExpression {
    public typealias ValueType = String
}

extension NSData : SelfExpression {}

extension NSNumber: SelfExpression, NSComparable, NumberType {}

extension Array: SelfExpression {}

extension Dictionary: SelfExpression {}

extension Set: SelfExpression {}
