//
//  Person.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/27.
//  Copyright (c) 2015 Nobuo Saito. All rights reserved.
//

import Foundation
import CoreData

class Person: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var age: NSNumber
    @NSManaged var parents: Set<Person>
    @NSManaged var children: Set<Person>

}
