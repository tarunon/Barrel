//
//  Planet+BarrelAttribute.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/10.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import Barrel
import Barrel_CoreData

extension AttributeType where ValueType: Planet {
    var semiMajorAxis: Attribute<NSNumber> { return attribute() }
    var parent: Attribute<Optional<Star>> { return attribute() }
    var children: Attribute<Many<Satellite>> { return attribute() }
}