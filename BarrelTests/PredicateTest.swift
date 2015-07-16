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
    
    func testEqualTo() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.age == 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age == %i", 20), "Pass")
            let p2: Predicate = $0.name == "John"
            XCTAssertEqual(p2.predicate(), NSPredicate(format: "name ==[cd] %@", "John"), "Pass")
            let p3: Predicate = $0.name === "John"
            XCTAssertEqual(p3.predicate(), NSPredicate(format: "name == %@", "John"), "Pass")
            return p1
            }.get()
    }

    func testNotEqualTo() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.age != 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age != %i", 20), "Pass")
            let p2: Predicate = $0.name != "John"
            XCTAssertEqual(p2.predicate(), NSPredicate(format: "name !=[cd] %@", "John"), "Pass")
            let p3: Predicate = $0.name !== "John"
            XCTAssertEqual(p3.predicate(), NSPredicate(format: "name != %@", "John"), "Pass")
            return p1
            }.get()
    }
    
    func testMatches() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.name ~= "^J.*n$"
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "name MATCHES[cd] %@", "^J.*n$"), "Pass")
            let p2: Predicate = $0.name ~== "^J.*n$"
            XCTAssertEqual(p2.predicate(), NSPredicate(format: "name MATCHES %@", "^J.*n$"), "Pass")
            return p1
            }.get()
    }
    
    func testGreaterThan() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.age > 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age > %i", 20), "Pass")
            return p1
            }.get()
    }
    
    func testGreaterThanOrEqualTo() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.age >= 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age >= %i", 20), "Pass")
            return p1
            }.get()
    }
    
    func testLessThan() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.age < 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age < %i", 20), "Pass")
            return p1
            }.get()
    }
    
    func testLessThanOrEqualTo() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.age <= 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age <= %i", 20), "Pass")
            return p1
            }.get()
    }
    
    func testIn() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.age << [19, 20, 21]
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age IN %@", [19, 20, 21]), "Pass")
            let p2: Predicate = $0.name << ["John", "Michael", "Harry"]
            XCTAssertEqual(p2.predicate(), NSPredicate(format: "name IN %@", ["John", "Michael", "Harry"]), "Pass")
            return p1
            }.get()
    }
    
//    unsupported at swift2.0 2015/07/06
//    func testBetween() {
//        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
//            let p1: Predicate = person.age << (19..<21)
//            XCTAssertEqual(p1.predicate(), NSPredicate(format: "age BETWEEN %@", [19, 21]), "Pass")
//            return p1
//            }.get()
//    }
    
    func testContains() {
        let child = context.insert(Person).insert()
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.children >> child
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "children CONTAINS %@", child), "Pass")
            return p1
            }.get()
    }
    
    func testAnd() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.name ~= "^J.*" && person.age >= 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "name MATCHES[cd] %@ AND age >= %i", "^J.*", 20), "Pass")
            return p1
        }.get()
    }
    
    func testOr() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = person.name ~= "^J.*" || person.age >= 20
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "name MATCHES[cd] %@ OR age >= %i", "^J.*", 20), "Pass")
            return p1
            }.get()
    }
    
    func testNot() {
        try! context.fetch(Person).filter{ (person: Person) -> Predicate in
            let p1: Predicate = !(person.name ~= "^J.*")
            XCTAssertEqual(p1.predicate(), NSPredicate(format: "NOT (name MATCHES[cd] %@)", "^J.*"), "Pass")
            return p1
            }.get()
    }
}
