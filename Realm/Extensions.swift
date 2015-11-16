//
//  Extensions.swift
//  BarrelRealm
//
//  Created by Nobuo Saito on 2015/11/10.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Barrel

extension Object : ExpressionType {
    public typealias ValueType = Object
}

public struct Many<T: Object where T: ExpressionType>: ExpressionType, ManyType {
    public typealias ValueType = List<T>
    public typealias ElementType = T
}

private extension NSSortDescriptor {
    func toRealmObject() -> SortDescriptor {
        return SortDescriptor(property: self.key!, ascending: self.ascending)
    }
}

public extension Realm {
    func objects<T: Object>() -> Results<T> {
        return self.objects(T.self)
    }
}

public protocol ObjectType {}

extension Object: ObjectType {}

public extension ObjectType where Self: Object {
    static func objects(realm: Realm) -> Results<Self> {
        return realm.objects()
    }
    
    static func insert(realm: Realm) -> Self {
        let object = Self()
        realm.add(object)
        return object
    }
}

public extension RealmCollectionType where Element: ExpressionType {
    func brl_filter(f: Attribute<Element> -> Predicate) -> Results<Element> {
        return self.filter(f(storedAttribute()).value)
    }
    
    func brl_indexOf(f: Attribute<Element> -> Predicate) -> Int? {
        return self.indexOf(f(storedAttribute()).value)
    }
    
    func brl_sorted(f: (Attribute<Element>, Attribute<Element>) -> SortDescriptors) -> Results<Element> {
        return self.sorted(f(storedAttribute(), storedAttribute("sort")).value.map { $0.toRealmObject() })
    }
    
    func brl_min<U: MinMaxType>(f: Attribute<Element> -> Attribute<U>) -> U? {
        return self.min(f(storedAttribute()).keyPath.string)
    }
    
    func brl_max<U: MinMaxType>(f: Attribute<Element> -> Attribute<U>) -> U? {
        return self.max(f(storedAttribute()).keyPath.string)
    }
    
    func brl_sum<U: AddableType>(f: Attribute<Element> -> Attribute<U>) -> U {
        return self.sum(f(storedAttribute()).keyPath.string)
    }
    
    func brl_average<U: AddableType>(f: Attribute<Element> -> Attribute<U>) -> U? {
        return self.average(f(storedAttribute()).keyPath.string)
    }
}