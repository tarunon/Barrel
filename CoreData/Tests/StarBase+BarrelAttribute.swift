//
//  StarBase+BarrelAttribute.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/17.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import Barrel
import Barrel_CoreData

extension AttributeType where ValueType: StarBase {
    var diameter: Attribute<NSNumber> { return attribute() }
    var name: Attribute<String> { return attribute() }
}