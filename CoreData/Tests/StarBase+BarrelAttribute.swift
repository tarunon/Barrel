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

extension AttributeType where FieldType: StarBase {
    var diameter: Attribute<NSNumber> { return storedAttribute(parent: self) }
    var name: Attribute<String> { return storedAttribute(parent: self) }
}