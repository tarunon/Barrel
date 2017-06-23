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
import Barrel_Realm

class StarBase: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var diameter: Double = 0.0
}

extension Attribute where ValueType: StarBase {
    var name: Attribute<String> { return attribute() }
    var diameter: Attribute<Double> { return attribute() }
}
