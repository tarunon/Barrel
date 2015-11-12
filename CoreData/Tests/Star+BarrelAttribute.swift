//
//  Star+BarrelAttribute.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/10.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import Barrel
import Barrel_CoreData

extension AttributeType where FieldType == Star {
    var diameter: Attribute<NSNumber> { return storedAttribute(__FUNCTION__, self) }
    var name: Attribute<String> { return storedAttribute(__FUNCTION__, self) }
    var children: Attribute<Many<Planet>> { return storedAttribute(__FUNCTION__, self) }
}