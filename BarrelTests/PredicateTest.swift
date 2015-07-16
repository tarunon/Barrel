//
//  PredicateTest.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/07/06.
//  Copyright (c) 2015年 tarunon. All rights reserved.
//

import UIKit
import XCTest
import Barrel
import CoreData

class PredicateTest: XCTestCase {

    var context: NSManagedObjectContext!
    var storeURL = NSURL(fileURLWithPath: "test.db")!
    
    override func setUp() {
        super.setUp()
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle(forClass: self.classForCoder).URLForResource("Person", withExtension: "momd")!)!)
        context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL , options: nil, error: nil)
    }
    
    override func tearDown() {
        context.save(nil)
        NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
        super.tearDown()
    }
    
    func testEqualTo() {
        context.fetch(Person).filter {
            let p1: Predicate = $0.age == 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age == %i", 20), "Pass")
            let p2: Predicate = $0.name == "John"
            XCTAssertEqual(p2.predicate(), NSPredicate(format: "name ==[cd] %@", "John"), "Pass")
            let p3: Predicate = $0.name === "John"
            XCTAssertEqual(p3.predicate(), NSPredicate(format: "name == %@", "John"), "Pass")
            return p1
        }.execute()
    }

    func testNotEqualTo() {
        context.fetch(Person).filter {
            let p1: Predicate = $0.age != 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age != %i", 20), "Pass")
            let p2: Predicate = $0.name != "John"
            XCTAssertEqual(p2.predicate(), NSPredicate(format: "name !=[cd] %@", "John"), "Pass")
            let p3: Predicate = $0.name !== "John"
            XCTAssertEqual(p3.predicate(), NSPredicate(format: "name != %@", "John"), "Pass")
            return p1
        }.execute()
    }
    
    func testMatches() {
        context.fetch(Person).filter {
            let p1: Predicate = $0.name ~= "^J.*n$"
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "name MATCHES[cd] %@", "^J.*n$"), "Pass")
            let p2: Predicate = $0.name ~== "^J.*n$"
            XCTAssertEqual(p2.predicate(), NSPredicate(format: "name MATCHES %@", "^J.*n$"), "Pass")
            return p1
        }.execute()
    }
    
    func testGreaterThan() {
        context.fetch(Person).filter {
            let p1: Predicate = $0.age > 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age > %i", 20), "Pass")
            return p1
        }.execute()
    }
    
    func testGreaterThanOrEqualTo() {
        context.fetch(Person).filter{
            let p1: Predicate = $0.age >= 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age >= %i", 20), "Pass")
            return p1
        }.execute()
    }
    
    func testLessThan() {
        context.fetch(Person).filter {
            let p1: Predicate = $0.age < 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age < %i", 20), "Pass")
            return p1
        }.execute()
    }
    
    func testLessThanOrEqualTo() {
        context.fetch(Person).filter {
            let p1: Predicate = $0.age <= 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age <= %i", 20), "Pass")
            return p1
        }.execute()
    }
    
    func testIn() {
        context.fetch(Person).filter {
            let p1: Predicate = $0.age << [19, 20, 21]
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age IN %@", [19, 20, 21]), "Pass")
            let p2: Predicate = $0.name << ["John", "Michael", "Harry"]
            XCTAssertEqual(p2.predicate(), NSPredicate(format: "name IN %@", ["John", "Michael", "Harry"]), "Pass")
            return p1
        }.execute()
    }

//unsupported at swift1.2
//    func testBetween() {
//        context.fetch(Person).filter {
//            let p1: Predicate = $0.age << (19..<21)
//            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age BETWEEN %@", [19, 21]), "Pass")
//            return p1
//        }.execute()
//    }
    
    func testContains() {
        let child = context.insert(Person).insert()
        context.fetch(Person).filter {
            let p1: Predicate = $0.children >> child
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "children CONTAINS %@", child), "Pass")
            return p1
        }.execute()
    }
    
    func testAnd() {
        context.fetch(Person).filter {
            let p1: Predicate = $0.name ~= "^J.*" && $0.age >= 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "name MATCHES[cd] %@ AND age >= %i", "^J.*", 20), "Pass")
            return p1
        }.execute()
    }
    
    func testOr() {
        context.fetch(Person).filter {
            let p1: Predicate = $0.name ~= "^J.*" || $0.age >= 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "name MATCHES[cd] %@ OR age >= %i", "^J.*", 20), "Pass")
            return p1
        }.execute()
    }
    
    func testNot() {
        context.fetch(Person).filter {
            let p1: Predicate = !($0.name ~= "^J.*")
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "NOT (name MATCHES[cd] %@)", "^J.*"), "Pass")
            return p1
        }.execute()
    }
}
