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
    var storeURL = NSURL(fileURLWithPath: "test.db")!
    
    override func setUp() {
        super.setUp()
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle(forClass: self.classForCoder).URLForResource("Person", withExtension: "momd")!)!)
        context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL , options: nil, error: nil)
        let datas: [[String: AnyObject]] = [["name": "John", "age": 18], ["name": "Michael", "age": 25], ["name": "Harry", "age": 39]]
        for data in datas {
            context.insert(Person).setKeyedValues(data).insert()
        }
        context.save(nil)
    }
    
    override func tearDown() {
        context.save(nil)
        NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
        super.tearDown()
    }
    
    func testFetchFilter() {
        let person = context.fetch(Person).filter{ $0.name == "John" }.execute().get()
        XCTAssertNotNil(person, "Pass")
        XCTAssertEqual(person!.name, "John", "Pass")
        let persons = context.fetch(Person).filter{ $0.age > 19 }.execute().all()
        XCTAssertEqual(persons.count, 2, "Pass")
        let empty1 = context.fetch(Person).filter{ $0.name == "John" && $0.age == 19 }.execute().get()
        XCTAssertNil(empty1, "Pass")
        let empty2 = context.fetch(Person).filter{ $0.name == "John" }.filter{ $0.age == 19 }.execute().get()
        XCTAssertNil(empty2, "Pass")
//        let children = context.fetch(Person).filter{ $0.parents == [person!] }.execute() // unsupported
    }
    
    func testFetchOrderBy() {
        let persons1 = context.fetch(Person).orderBy{ $0.age < $1.age }.execute().all()
        for i in 0..<persons1.count - 1 {
            XCTAssertLessThanOrEqual(persons1[i].age.integerValue, persons1[i + 1].age.integerValue, "Pass")
        }
        let persons2 = context.fetch(Person).orderBy{ $1.age < $0.age }.execute().all()
        for i in 0..<persons2.count - 1 {
            XCTAssertGreaterThanOrEqual(persons2[i].age.integerValue, persons2[i + 1].age.integerValue, "Pass")
        }
    }
    
    func testFetchLimit() {
        let persons = context.fetch(Person).limit(2).execute().all()
        XCTAssertEqual(persons.count, 2, "Pass")
    }
    
    func testFetchOffset() {
        let persons1 = context.fetch(Person).orderBy{ $0.age < $1.age }.offset(0).execute().all()
        let persons2 = context.fetch(Person).orderBy{ $0.age < $1.age }.offset(1).execute().all()
        for i in 0..<persons2.count {
            XCTAssertEqual(persons1[i + 1], persons2[i], "Pass")
        }
    }
    
    func testPerformanceUseFetchObject() {
        measureBlock {
            for i in 0..<1000 {
                let persons = self.context.fetch(Person).filter{ $0.name !== "John" }.orderBy{ $0.age > $1.age }.execute().all()
            }
        }
    }
    
    func testPerformanceNoUseFetchObject() {
        measureBlock {
            for i in 0..<1000 {
                let fetchRequest = NSFetchRequest(entityName: "PersonEntity")
                fetchRequest.predicate = NSPredicate(format: "name != %@", "John")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "age", ascending: false)]
                let persons = self.context.executeFetchRequest(fetchRequest, error: nil) as? [Person] ?? []
            }
        }
    }
}
