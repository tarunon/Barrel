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

extension List: ExpressionType, ManyType where Element: ExpressionType {
    public typealias ValueType = List
    public typealias _ElementType = ExpressionWrapper<Element>
}

extension LinkingObjects: ExpressionType, ManyType where Element: ExpressionType {
    public typealias ValueType = LinkingObjects
    public typealias _ElementType = ExpressionWrapper<Element>
}

internal extension NSSortDescriptor {
    func toRealmObject() -> SortDescriptor {
        return SortDescriptor(keyPath: self.key!, ascending: ascending)
    }
}

public protocol RealmObjectType {

}

extension Object: RealmObjectType {

}

public extension RealmObjectType where Self: Object {
    public static func objects(_ realm: Realm) -> Results<Self> {
        return realm.objects(Self.self)
    }
    
    public static func insert(_ realm: Realm) -> Self {
        let object = Self()
        realm.add(object)
        return object
    }
}
