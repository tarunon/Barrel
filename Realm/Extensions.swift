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
    public typealias ElementType = ExpressionWrapper<T>
}

extension LinkingObjects: ExpressionType, ManyType {
    public typealias ValueType = LinkingObjects
    public typealias ElementType = ExpressionWrapper<T>
}

internal extension NSSortDescriptor {
    func toRealmObject() -> SortDescriptor {
        return SortDescriptor(keyPath: self.key!, ascending: ascending)
    }
}

public extension Realm {
    func objects<T>() -> Results<T> {
        return self.objects(T.self)
    }
}

public protocol RealmObjectType {

}

extension Object: RealmObjectType {

}

public extension RealmObjectType where Self: Object {
    public static func objects(_ realm: Realm) -> Results<Self> {
        return realm.objects()
    }
    
    public static func insert(_ realm: Realm) -> Self {
        let object = Self()
        realm.add(object)
        return object
    }
}
