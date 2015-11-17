//
//  Planet+CoreDataProperties.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/17.
//  Copyright © 2015年 tarunon. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Planet {

    @NSManaged var semiMajorAxis: NSNumber
    @NSManaged var children: Set<Satellite>
    @NSManaged var parent: Star?

}
