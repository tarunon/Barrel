//
//  Planet.swift
//  BarrelRealm
//
//  Created by Nobuo Saito on 2015/11/10.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Barrel
@testable import Barrel_Realm

class Planet: StarBase {
    dynamic var semiMajorAxis: Double = 0.0
    
    dynamic var parent: Star?
    
    var children: [Satellite] {
        return self.linkingObjects(Satellite.self, forProperty: "parent")
    }
}

extension AttributeType where ValueType: Planet {
    var semiMajorAxis: Attribute<Double> { return attribute() }
    var parent: Attribute<Optional<Star>> { return attribute() }
}