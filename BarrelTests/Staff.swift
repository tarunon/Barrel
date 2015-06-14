//
//  Staff.swift
//  Barrel
//
//  Created by 齋藤暢郎 on 2015/06/14.
//  Copyright (c) 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData

class Staff: Person {

    @NSManaged var post: String
    @NSManaged var chief: Staff?
    @NSManaged var subordinate: Set<Staff>

}
