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

extension AttributeType where FieldType == Planet {
    var diameter: Attribute<NSNumber> { return storedAttribute(__FUNCTION__, self) }
    var name: Attribute<String> { return storedAttribute(__FUNCTION__, self) }
    var semiMajorAxis: Attribute<NSNumber> { return storedAttribute(__FUNCTION__, self) }
    var parent: OptionalAttribute<Star> { return storedAttribute(__FUNCTION__, self) }
    var children: Attribute<Many<Satellite>> { return storedAttribute(__FUNCTION__, self) }
}