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
    func compare(_ other: Self) -> ComparisonResult
}

public func <<C: NSComparable>(lhs: C, rhs: C) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

public func <=<C: NSComparable>(lhs: C, rhs: C) -> Bool {
    return lhs.compare(rhs) != .orderedDescending
}

public func >=<C: NSComparable>(lhs: C, rhs: C) -> Bool {
    return lhs.compare(rhs) != .orderedAscending
}

public func ><C: NSComparable>(lhs: C, rhs: C) -> Bool {
    return lhs.compare(rhs) == .orderedDescending
}

public protocol SelfExpression : ExpressionType where ValueType == Self {
    associatedtype ValueType = Self
}

extension Double : SelfExpression, NumberType {
    public typealias ValueType = Double
}

extension Int16 : SelfExpression, NumberType {
    public typealias ValueType = Int16
}

extension Int32 : SelfExpression, NumberType {
    public typealias ValueType = Int32
}

extension Int64 : SelfExpression, NumberType {
    public typealias ValueType = Int64
}

extension Float : SelfExpression, NumberType {
    public typealias ValueType = Float
}

extension Bool : SelfExpression, NumberType {
    public typealias ValueType = Bool
}

extension Int : SelfExpression , NumberType {
    public typealias ValueType = Int
}

extension Date : SelfExpression, NSComparable {
    public typealias ValueType = Date
}

extension String : SelfExpression {
    public typealias ValueType = String
}

extension Data : SelfExpression {
    public typealias ValueType = Data
}

extension NSNumber: SelfExpression, NSComparable, NumberType {
    public typealias ValueType = NSNumber
}

extension Array: SelfExpression where Element: ExpressionType {
    public typealias ValueType = Array
}

extension Dictionary: SelfExpression where Value: ExpressionType {
    public typealias ValueType = Dictionary
}

extension Set: SelfExpression where Element: ExpressionType {
    public typealias ValueType = Set
}
