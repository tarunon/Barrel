//
//  Star.swift
//  BarrelRealm
//
//  Created by Nobuo Saito on 2015/11/10.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Barrel
@testable import Barrel_Realm

class Star: Object {
    dynamic var name: String = ""
    dynamic var diameter: Double = 0.0
    var children: [Planet] {
        return self.linkingObjects(Planet.self, forProperty: "parent")
    }
}

extension AttributeType where FieldType == Star {
    var name: Attribute<String> { return storedAttribute(parent: self) }
    var diameter: Attribute<Double> { return storedAttribute(parent: self) }
}