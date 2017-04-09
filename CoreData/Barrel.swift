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

public protocol GroupType {
    associatedtype AttributeSourceType: NSManagedObject
    func groupBy(_ keyPath: @autoclosure @escaping () -> KeyPath) -> Self
    func having(_ predicate: @autoclosure @escaping () -> NSPredicate) -> Self
}

extension Group: GroupType {
    public typealias AttributeSourceType = T
}

public protocol AggregateType {
    associatedtype AttributeSourceType: NSManagedObject
    func aggregate(_ expressionDescription: @autoclosure @escaping () -> NSExpressionDescription) -> Self
    func groupBy(_ keyPath: @autoclosure @escaping () -> KeyPath) -> Group<AttributeSourceType>
}

extension Aggregate: AggregateType {
    public typealias AttributeSourceType = T
}

public protocol FetchType {
    associatedtype AttributeSourceType: NSManagedObject
    func filter(_ predicate: @autoclosure @escaping () -> NSPredicate) -> Self
    func sorted(_ sortDescriptor: @autoclosure @escaping () -> [NSSortDescriptor]) -> Self
    func limit(_ limit: Int) -> Self
    func offset(_ offset: Int) -> Self
    func aggregate(_ expressionDescription: @autoclosure @escaping () -> NSExpressionDescription) -> Aggregate<AttributeSourceType>
}

extension Fetch: FetchType {
    public typealias AttributeSourceType = T
}

public struct Barrel<Base: Executable> {
    public let base: Base
    public func confirm() -> Base {
        return base
    }
}

extension Executable {
    public var brl: Barrel<Self> {
        return Barrel(base: self)
    }
}

extension Barrel where Base: FetchType, Base.AttributeSourceType: ExpressionType {
    public func filter(_ f: @escaping (Attribute<ExpressionWrapper<Base.AttributeSourceType>>) -> Predicate) -> Barrel {
        return Barrel(base: base.filter(f(Attribute()).value))
    }

    public func sorted(_ f: @escaping (Attribute<ExpressionWrapper<Base.AttributeSourceType>>, Attribute<ExpressionWrapper<Base.AttributeSourceType>>) -> SortDescriptors) -> Barrel {
        return Barrel(base: base.sorted(f(Attribute.sortAttributeFirst(), Attribute.sortAttributeSecond()).value))
    }

    public func aggregate<E: ExpressionType, V: ExpressionType>(_ f: @escaping (Attribute<ExpressionWrapper<Base.AttributeSourceType>>) -> E) -> Barrel<Aggregate<Base.AttributeSourceType>> where E.ValueType == V {
        return Barrel<Aggregate<Base.AttributeSourceType>>(base: base.aggregate(Expression(f(Attribute())).expressionDescription()))
    }
}

extension Barrel where Base: AggregateType, Base.AttributeSourceType: ExpressionType {
    public func aggregate<E: ExpressionType, V: ExpressionType>(_ f: @escaping (Attribute<ExpressionWrapper<Base.AttributeSourceType>>) -> E) -> Barrel where E.ValueType == V {
        return Barrel(base: base.aggregate(Expression(f(Attribute())).expressionDescription()))
    }

    public func groupBy<E: ExpressionType>(_ f: @escaping (Attribute<ExpressionWrapper<Base.AttributeSourceType>>) -> Attribute<E>) -> Barrel<Group<Base.AttributeSourceType>> {
        return Barrel<Group<Base.AttributeSourceType>>(base: base.groupBy(f(Attribute()).keyPath))
    }
}

extension Barrel where Base: GroupType, Base.AttributeSourceType: ExpressionType {
    public func groupBy<E: ExpressionType>(_ f: @escaping (Attribute<ExpressionWrapper<Base.AttributeSourceType>>) -> Attribute<E>) -> Barrel {
        return Barrel(base: base.groupBy(f(Attribute()).keyPath))
    }

    public func having(_ f: @escaping (Attribute<ExpressionWrapper<Base.AttributeSourceType>>) -> Predicate) -> Barrel {
        return Barrel(base: base.having(f(Attribute()).value))
    }
}
