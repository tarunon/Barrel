//
//  Barrel.swift
//  Barrel
//
//  Created by Nobuo Saito on 2016/11/22.
//  Copyright © 2016年 tarunon. All rights reserved.
//

import Foundation
import CoreData
import Barrel

public protocol GroupType: Executable {
    typealias ElementType = NSDictionary
    associatedtype AttributeSourceType
    func groupBy(_ keyPath: @autoclosure @escaping () -> KeyPath) -> Self
    func having(_ predicate: @autoclosure @escaping () -> NSPredicate) -> Self
}

extension Group: GroupType {
    public typealias AttributeSourceType = T
}

public protocol AggregateType: Executable {
    typealias ElementType = NSDictionary
    associatedtype AttributeSourceType
    func aggregate(_ expressionDescription: @autoclosure @escaping () -> NSExpressionDescription) -> Self
    func _groupBy<G: GroupType>(_ keyPath: @autoclosure @escaping () -> KeyPath) -> G where G.AttributeSourceType == AttributeSourceType
}

extension Aggregate: AggregateType {
    public typealias AttributeSourceType = T
    public func _groupBy<G: GroupType>(_ keyPath: @autoclosure @escaping () -> KeyPath) -> G where G.AttributeSourceType == AttributeSourceType {
        return self.groupBy(keyPath) as! G
    }
}

public protocol FetchType: Executable {
    associatedtype ElementType: ExpressionType
    associatedtype AttributeSourceType
    func filter(_ predicate: @autoclosure @escaping () -> NSPredicate) -> Self
    func sorted(_ sortDescriptor: @autoclosure @escaping () -> [NSSortDescriptor]) -> Self
    func limit(_ limit: Int) -> Self
    func offset(_ offset: Int) -> Self
    func _aggregate<A: AggregateType>(_ expressionDescription: @autoclosure @escaping () -> NSExpressionDescription) -> A where A.AttributeSourceType == AttributeSourceType
}

extension Fetch: FetchType {
    public typealias AttributeSourceType = T
    public func _aggregate<A: AggregateType>(_ expressionDescription: @autoclosure @escaping () -> NSExpressionDescription) -> A where A.AttributeSourceType == AttributeSourceType {
        return self.aggregate(expressionDescription()) as! A
    }
}



public protocol BarrelType {
    associatedtype Base: Executable
    var base: Base { get }
}

public struct Barrel<E: Executable>: BarrelType {
    public typealias Base = E
    public let base: E
    public func confirm() -> E {
        return base
    }
}

extension Executable {
    public var brl: Barrel<Self> {
        return Barrel(base: self)
    }
}

extension BarrelType where Base: FetchType, Base.AttributeSourceType: NSManagedObject, Base.AttributeSourceType: ExpressionType {
    public func filter(_ f: @escaping (Attribute<Base.AttributeSourceType>) -> Predicate) -> Barrel<Base> {
        return Barrel(base: base.filter(f(Attribute()).value))
    }

    public func sorted(_ f: @escaping (Attribute<Base.AttributeSourceType>, Attribute<Base.AttributeSourceType>) -> SortDescriptors) -> Barrel<Base> {
        return Barrel(base: base.sorted(f(Attribute(), Attribute(name: "sort")).value))
    }

    public func aggregate<E: ExpressionType, V: ExpressionType>(_ f: @escaping (Attribute<Base.AttributeSourceType>) -> E) -> Barrel<Aggregate<Base.AttributeSourceType>> where E.ValueType == V {
        return Barrel(base: base._aggregate(unwrapExpression(f(Attribute())).expressionDescription()))
    }
}

extension BarrelType where Base: AggregateType, Base.AttributeSourceType: NSManagedObject, Base.AttributeSourceType: ExpressionType {
    public func aggregate<E: ExpressionType, V: ExpressionType>(_ f: @escaping (Attribute<Base.AttributeSourceType>) -> E) -> Barrel<Base> where E.ValueType == V {
        return Barrel(base: base.aggregate(unwrapExpression(f(Attribute())).expressionDescription()))
    }

    public func groupBy<E: ExpressionType>(_ f: @escaping (Attribute<Base.AttributeSourceType>) -> Attribute<E>) -> Barrel<Group<Base.AttributeSourceType>> {
        return Barrel(base: base._groupBy(f(Attribute()).keyPath))
    }
}

extension BarrelType where Base: GroupType, Base.AttributeSourceType: NSManagedObject, Base.AttributeSourceType: ExpressionType {
    public func groupBy<E: ExpressionType>(_ f: @escaping (Attribute<Base.AttributeSourceType>) -> Attribute<E>) -> Barrel<Base> {
        return Barrel(base: base.groupBy(f(Attribute()).keyPath))
    }

    public func having(_ f: @escaping (Attribute<Base.AttributeSourceType>) -> Predicate) -> Barrel<Base> {
        return Barrel(base: base.having(f(Attribute()).value))
    }
}
