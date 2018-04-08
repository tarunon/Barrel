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

@available(*, unavailable, renamed: "ExpressionType")
public typealias SelfExpression = ExpressionType

extension Double : ExpressionType, NumberType {
    
}

extension Int16 : ExpressionType, NumberType {
    
}

extension Int32 : ExpressionType, NumberType {
    
}

extension Int64 : ExpressionType, NumberType {
    
}

extension Float : ExpressionType, NumberType {
    
}

extension Bool : ExpressionType, NumberType {
    
}

extension Int : ExpressionType , NumberType {
    
}

extension Date : ExpressionType, NSComparable {
    
}

extension String : ExpressionType {
    
}

extension Data : ExpressionType {
    
}

extension NSNumber: ExpressionType, NSComparable, NumberType {
    
}

extension Array: ExpressionType where Element: ExpressionType {
    
}

extension Dictionary: ExpressionType where Value: ExpressionType {
    
}

extension Set: ExpressionType where Element: ExpressionType {
    
}

extension Optional: ExpressionType where Wrapped: ExpressionType {
    public typealias ValueType = Wrapped
}
