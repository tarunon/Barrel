//
//  Protocols.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public protocol NumberType {}

//public protocol NSComparable: Comparable {
//    func compare(_ other: Self) -> ComparisonResult
//}
//
//public func <<C: NSComparable>(lhs: C, rhs: C) -> Bool {
//    return lhs.compare(rhs) == .orderedAscending
//}
//
//public func <=<C: NSComparable>(lhs: C, rhs: C) -> Bool {
//    return lhs.compare(rhs) != .orderedDescending
//}
//
//public func >=<C: NSComparable>(lhs: C, rhs: C) -> Bool {
//    return lhs.compare(rhs) != .orderedAscending
//}
//
//public func ><C: NSComparable>(lhs: C, rhs: C) -> Bool {
//    return lhs.compare(rhs) == .orderedDescending
//}

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

extension Date : SelfExpression {}

extension String : SelfExpression {
    public typealias ValueType = String
}

extension Data : SelfExpression {}

extension NSNumber: SelfExpression, NumberType {}

extension Array: SelfExpression {}

extension Dictionary: SelfExpression {}

extension Set: SelfExpression {}
