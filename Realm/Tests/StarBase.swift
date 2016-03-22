//
//  StarBase.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/17.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Barrel
@testable import Barrel_Realm

class StarBase: Object {
    dynamic var name: String = ""
    dynamic var diameter: Double = 0.0
}

extension AttributeType where ValueType: StarBase {
    var name: Attribute<String> { return attribute() }
    var diameter: Attribute<Double> { return attribute() }
}