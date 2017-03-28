//
//  Barrel.swift
//  Barrel
//
//  Created by Nobuo Saito on 2016/11/22.
//  Copyright © 2016年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Barrel

public protocol BarrelType {
    associatedtype Base: RealmCollection
    var base: Base { get }
}

public struct Barrel<R: RealmCollection>: BarrelType {
    public typealias Base = R
    public let base: R
    public func confirm() -> R {
        return base
    }
}

extension RealmCollection {
    public var brl: Barrel<Self> {
        return Barrel(base: self)
    }
}

public extension BarrelType where Base: RealmCollection {
    func filter(_ f: (Attribute<ExpressionWrapper<Base.Element>>) -> Predicate) -> Barrel<Results<Base.Element>> {
        return Barrel(base: base.filter(f(Attribute()).value))
    }

    func indexOf(_ f: (Attribute<ExpressionWrapper<Base.Element>>) -> Predicate) -> Int? {
        return base.index(matching: f(Attribute()).value)
    }

    func sorted(_ f: (Attribute<ExpressionWrapper<Base.Element>>, Attribute<ExpressionWrapper<Base.Element>>) -> SortDescriptors) -> Barrel<Results<Base.Element>> {
        return Barrel(base: base.sorted(by: f(Attribute.sortAttributeFirst(), Attribute.sortAttributeSecond()).value.map { $0.toRealmObject() }))
    }

    func min<U: MinMaxType>(_ f: (Attribute<ExpressionWrapper<Base.Element>>) -> Attribute<U>) -> U? {
        return base.min(ofProperty: f(Attribute()).keyPath.string)
    }

    func max<U: MinMaxType>(_ f: (Attribute<ExpressionWrapper<Base.Element>>) -> Attribute<U>) -> U? {
        return base.max(ofProperty: f(Attribute()).keyPath.string)
    }

    func sum<U: AddableType>(_ f: (Attribute<ExpressionWrapper<Base.Element>>) -> Attribute<U>) -> U {
        return base.sum(ofProperty: f(Attribute()).keyPath.string)
    }

    func average<U: AddableType>(_ f: (Attribute<ExpressionWrapper<Base.Element>>) -> Attribute<U>) -> U? {
        return base.average(ofProperty: f(Attribute()).keyPath.string)
    }
}
