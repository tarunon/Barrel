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
import Barrel_Realm

class Star: StarBase {
    let children: LinkingObjects<Planet> = LinkingObjects(fromType: Planet.self, property: "parent")
}

extension AttributeType where ValueType: Star {
    var children: Attribute<LinkingObjects<Planet>> { return attribute() }
}