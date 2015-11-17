//
//  Satellite+CoreDataProperties.swift
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

extension Satellite {

    @NSManaged var semiMajorAxis: NSNumber
    @NSManaged var parent: Planet?

}
