//
//  Satellite+BarrelAttribute.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/10.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import Barrel
import Barrel_CoreData

extension Attribute where T: Satellite {
    var semiMajorAxis: Attribute<NSNumber> { return attribute() }
    var parent: Attribute<Optional<Planet>> { return attribute() }
}
