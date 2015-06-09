//
//  FetchTest.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/28.
//  Copyright (c) 2015 Nobuo Saito. All rights reserved.
//

import Foundation
import CoreData
import Barrel
import XCTest

class FetchTest: XCTestCase {
        
    var context: NSManagedObjectContext!
    var storeURL = NSURL(fileURLWithPath: "test.db")
    
    override func setUp() {
        super.setUp()
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle(forClass: self.classForCoder).URLForResource("Person", withExtension: "momd")!)!)
        try! context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL , options: nil)
        let datas: [[String: AnyObject]] = [["name": "John", "age": 18], ["name": "Michael", "age": 25], ["name": "Harry", "age": 39]]
        for data in datas {
            context.insert(Person).setKeyedValues(data).insert()
        }
        try! context.save()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try! NSFileManager.defaultManager().removeItemAtURL(storeURL)
        super.tearDown()
    }
    
    func testFetchFilter() {
        let person = try! context.fetch(Person).filter{ $0.name == "John" }.get()
        XCTAssertNotNil(person, "Pass")
        XCTAssertEqual(person!.name, "John", "Pass")
        let persons = try! context.fetch(Person).filter{ $0.age > 19 }.all()
        XCTAssertEqual(persons.count, 2, "Pass")
        let empty1 = try! context.fetch(Person).filter{ $0.name == "John" && $0.age == 19 }.get()
        XCTAssertNil(empty1, "Pass")
        let empty2 = try! context.fetch(Person).filter{ $0.name == "John" }.filter{ $0.age == 19 }.get()
        XCTAssertNil(empty2, "Pass")
//        let children = context.fetch(Person).filter{ $0.parents == [person!] }.execute() // unsupported
    }
    
    func testFetchOrderBy() {
        let persons = try! context.fetch(Person).orderBy{ $0.age < $1.age }.all()
        for i in 0..<persons.count - 1 {
            XCTAssertLessThanOrEqual(persons[i].age.integerValue, persons[i + 1].age.integerValue, "Pass")
        }
    }
    
    func testFetchLimit() {
        let persons = try! context.fetch(Person).limit(2).all()
        XCTAssertEqual(persons.count, 2, "Pass")
    }
    
    func testFetchOffset() {
        let persons1 = try! context.fetch(Person).orderBy{ $0.age < $1.age }.offset(0).all()
        print(persons1)
        let persons2 = try! context.fetch(Person).orderBy{ $0.age < $1.age }.offset(1).all()
        print(persons2)
        for i in 0..<persons2.count {
            XCTAssertEqual(persons1[i + 1], persons2[i], "Pass")
        }
    }
    
    func testPerformanceUseFetchObject() {
        measureBlock { () -> Void in
            for _ in 0..<1000 {
                try! self.context.fetch(Person).filter{ $0.name != "John" }.orderBy{ $0.age > $1.age }.all()
            }
        }
    }
    
    func testPerformanceNoUseFetchObject() {
        measureBlock { () -> Void in
            for _ in 0..<1000 {
                let fetchRequest = NSFetchRequest(entityName: "PersonEntity")
                fetchRequest.predicate = NSPredicate(format: "name != %@", "John")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "age", ascending: false)]
                try! self.context.executeFetchRequest(fetchRequest) as? [Person] ?? []
            }
        }
    }
}
