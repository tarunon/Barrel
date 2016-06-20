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

extension Object: ExpressionType {
    public typealias ValueType = Object
}

extension List: ExpressionType, ManyType {
    public typealias ValueType = List
    public typealias ElementType = T
}

extension LinkingObjects: ExpressionType, ManyType {
    public typealias ValueType = LinkingObjects
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

public extension ExpressionType where Self: Object {
    public typealias ValueType = Self
    public static func objects(realm: Realm) -> Results<Self> {
        return realm.objects()
    }
    
    public static func insert(realm: Realm) -> Self {
        let object = Self()
        realm.add(object)
        return object
    }
}

public extension RealmCollectionType where Element: ExpressionType {
    func brl_filter(f: Attribute<Element> -> Predicate) -> Results<Element> {
        return self.filter(f(Attribute()).value)
    }
    
    func brl_indexOf(f: Attribute<Element> -> Predicate) -> Int? {
        return self.indexOf(f(Attribute()).value)
    }
    
    func brl_sorted(f: (Attribute<Element>, Attribute<Element>) -> SortDescriptors) -> Results<Element> {
        return self.sorted(f(Attribute(), Attribute(name: "sort")).value.map { $0.toRealmObject() })
    }
    
    func brl_min<U: MinMaxType>(f: Attribute<Element> -> Attribute<U>) -> U? {
        return self.min(f(Attribute()).keyPath.string)
    }
    
    func brl_max<U: MinMaxType>(f: Attribute<Element> -> Attribute<U>) -> U? {
        return self.max(f(Attribute()).keyPath.string)
    }
    
    func brl_sum<U: AddableType>(f: Attribute<Element> -> Attribute<U>) -> U {
        return self.sum(f(Attribute()).keyPath.string)
    }
    
    func brl_average<U: AddableType>(f: Attribute<Element> -> Attribute<U>) -> U? {
        return self.average(f(Attribute()).keyPath.string)
    }
}
