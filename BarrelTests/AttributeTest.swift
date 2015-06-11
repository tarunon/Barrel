//
//  AttributeTest.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/31.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData
import Barrel
import XCTest

class AttributeTest: XCTestCase {

    var context: NSManagedObjectContext!
    var storeURL = NSURL(fileURLWithPath: "test.db")
    
    override func setUp() {
        super.setUp()
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle(forClass: self.classForCoder).URLForResource("Person", withExtension: "momd")!)!)
        do {
            try context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL , options: nil)
        } catch _ {
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        do {
            // Put teardown code here. This method is called after the invocation of each test method in the class.
            try NSFileManager.defaultManager().removeItemAtURL(storeURL)
        } catch _ {
        }
        super.tearDown()
    }

    func testAttributeInFetch() {
        let personFetchRequest = context.fetch(Person).filter{ $0.name == "John" && $0.age == 20 }.orderBy{ $0.age < $1.age }.fetchRequest()
        XCTAssertNotNil(personFetchRequest.predicate, "Pass")
        XCTAssertEqual(personFetchRequest.predicate!, NSCompoundPredicate(type: .AndPredicateType, subpredicates: [NSPredicate(value: true), NSPredicate(format: "name == %@ && age == %i", "John", 20)]), "Pass")
        XCTAssertNotNil(personFetchRequest.sortDescriptors, "Pass")
        XCTAssertEqual(personFetchRequest.sortDescriptors!, [NSSortDescriptor(key: "age", ascending: true)], "Pass")

        let staffFetchRequest = context.fetch(Staff).filter{ $0.name == "John" && $0.age == 20 }.orderBy{ $0.age < $1.age }.fetchRequest()
        XCTAssertNotNil(staffFetchRequest.predicate, "Pass")
        XCTAssertEqual(staffFetchRequest.predicate!, NSCompoundPredicate(type: .AndPredicateType, subpredicates: [NSPredicate(value: true), NSPredicate(format: "name == %@ && age == %i", "John", 20)]), "Pass")
        XCTAssertNotNil(staffFetchRequest.sortDescriptors, "Pass")
        XCTAssertEqual(staffFetchRequest.sortDescriptors!, [NSSortDescriptor(key: "age", ascending: true)], "Pass")
    }
}
