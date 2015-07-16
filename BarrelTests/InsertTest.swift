//
//  InsertTest.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/27.
//  Copyright (c) 2015 Nobuo Saito. All rights reserved.
//

import Foundation
import CoreData
import Barrel
import XCTest

class InsertTest: XCTestCase {

    var context: NSManagedObjectContext!
    var storeURL = NSURL(fileURLWithPath: "test.db")
    
    override func setUp() {
        super.setUp()
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle(forClass: self.classForCoder).URLForResource("Person", withExtension: "momd")!)!)
        try! context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL , options: nil)
    }
    
    override func tearDown() {
        try! context.save()
        try! NSFileManager.defaultManager().removeItemAtURL(storeURL)
        super.tearDown()
    }
    
    func testInsertValue() {
        let person1 = context.insert(Person).setValue("John", forKey: "name").insert()
        XCTAssertEqual(person1.name, "John", "Pass")
        let personCount1 = try! context.fetch(Person).count()
        XCTAssertEqual(personCount1, 1, "Pass")
        let person2 = context.insert(Person).setValues(["John", 12], forKeys: ["name", "age"]).insert()
        XCTAssertEqual([person2.name, person2.age], ["John", 12], "Pass")
        let personCount2 = try! context.fetch(Person).count()
        XCTAssertEqual(personCount2, 2, "Pass")
        let person3 = context.insert(Person).setKeyedValues(["name": "John", "age": 12]).insert()
        XCTAssertEqual([person3.name, person3.age], ["John", 12], "Pass")
        let personCount3 = try! context.fetch(Person).count()
        XCTAssertEqual(personCount3, 3, "Pass")
        let person4 = context.insert(Person).setValues{
            $0.name = "John"
            $0.age = 0
            }.insert()
        XCTAssertEqual([person4.name, person4.age], ["John", 0], "Pass")
        let personCount4 = try! context.fetch(Person).count()
        XCTAssertEqual(personCount4, 4, "Pass")
    }
    
    func testInsertRelationship() {
        let person1 = context.insert(Person).insert()
        let person2 = context.insert(Person).setValues{ $0.parents = [person1] }.insert()
        XCTAssertEqual(person1, person2.parents.first!, "Pass")
        XCTAssertEqual(person2, person1.children.first!, "Pass")
    }
    
    func testGetOrInsert() {
        let person1 = context.insert(Person).setValues{ $0.name = "Michael" }.getOrInsert()
        let person2 = context.insert(Person).setValues{ $0.name = "Michael" }.getOrInsert()
        let person3 = context.insert(Person).setValues{ $0.name = "Michael" }.getOrInsert()
        let personCount1 = try! context.fetch(Person).count()
        XCTAssertEqual(personCount1, 1, "Pass")
        XCTAssertEqual(person1, person2, "Pass")
        XCTAssertEqual(person1, person3, "Pass")
        let person4 = context.insert(Person).setValues{
            $0.name = "Michael"
            $0.age = 25
            }.getOrInsert()
        let person5 = context.insert(Person).setValues{
            $0.name = "Michael"
            $0.age = 25
            }.getOrInsert()
        XCTAssertEqual(person4, person5, "Pass")
        XCTAssertNotEqual(person1, person5, "Pass")
        let personCount2 = try! context.fetch(Person).count()
        XCTAssertEqual(personCount2, 2, "Pass")
    }
    
    func testPerformanceUseInsertObject() {
        measureBlock {
            for _ in 0..<1000 {
                _ = self.context.insert(Person).setValues{
                    $0.name = "Harry"
                    $0.age = 39
                    }.insert()
            }
        }
    }
    
    func testPerformanceNoUseInsertObject() {
        measureBlock {
            for _ in 0..<1000 {
                let person = NSEntityDescription.insertNewObjectForEntityForName("PersonEntity", inManagedObjectContext: self.context) as! Person
                person.name = "Harry"
                person.age = 39
                self.context.refreshObject(person, mergeChanges: true)
            }
        }
    }
}
