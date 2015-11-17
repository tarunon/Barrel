//
//  Satellite.swift
//  BarrelRealm
//
//  Created by Nobuo Saito on 2015/11/10.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Barrel
@testable import Barrel_Realm

class Satellite: Object {
    dynamic var name: String = ""
    dynamic var diameter: Double = 0.0
    dynamic var semiMajorAxis: Double = 0.0
    
    dynamic var parent: Planet?
}

extension AttributeType where FieldType == Satellite {
    var name: Attribute<String> { return storedAttribute(parent: self) }
    var diameter: Attribute<Double> { return storedAttribute(parent: self) }
    var semiMajorAxis: Attribute<Double> { return storedAttribute(parent: self) }
    var parent: OptionalAttribute<Planet> { return storedAttribute(parent: self) }
}