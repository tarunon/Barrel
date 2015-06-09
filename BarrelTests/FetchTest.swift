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
        do {
            try context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL , options: nil)
        } catch _ {
        }
        let datas: [[String: AnyObject]] = [["name": "John", "age": 18], ["name": "Michael", "age": 25], ["name": "Harry", "age": 39]]
        for data in datas {
            context.insert(Person).setKeyedValues(data).insert()
        }
        do {
            try context.save()
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
    
    func testFetchFilter() {
        do {
            let person = try context.fetch(Person).filter{ $0.name == "John" }.get()
            XCTAssertNotNil(person, "Pass")
            XCTAssertEqual(person!.name, "John", "Pass")
            let persons = try context.fetch(Person).filter{ $0.age > 19 }.all()
            XCTAssertEqual(persons.count, 2, "Pass")
            let empty1 = try context.fetch(Person).filter{ $0.name == "John" && $0.age == 19 }.get()
            XCTAssertNil(empty1, "Pass")
            let empty2 = try context.fetch(Person).filter{ $0.name == "John" }.filter{ $0.age == 19 }.get()
            XCTAssertNil(empty2, "Pass")
        } catch {
            
        }
//        let children = context.fetch(Person).filter{ $0.parents == [person!] }.execute() // unsupported
    }
    
    func testFetchOrderBy() {
        do {
            let persons = try context.fetch(Person).orderBy{ $0.age < $1.age }.all()
            for i in 0..<persons.count - 1 {
                XCTAssertLessThanOrEqual(persons[i].age.integerValue, persons[i + 1].age.integerValue, "Pass")
            }
        } catch {
            
        }
    }
    
    func testFetchLimit() {
        do {
            let persons = try context.fetch(Person).limit(2).all()
            XCTAssertEqual(persons.count, 2, "Pass")
        } catch {
            
        }
    }
    
    func testFetchOffset() {
        do {
            let persons1 = try context.fetch(Person).orderBy{ $0.age < $1.age }.offset(0).all()
            print(persons1)
            let persons2 = try context.fetch(Person).orderBy{ $0.age < $1.age }.offset(1).all()
            print(persons2)
            for i in 0..<persons2.count {
                XCTAssertEqual(persons1[i + 1], persons2[i], "Pass")
            }
        } catch {
            
        }
    }
    
    func testPerformanceUseFetchObject() {
        measureBlock { () -> Void in
            do {
                for _ in 0..<1000 {
                    try self.context.fetch(Person).filter{ $0.name != "John" }.orderBy{ $0.age > $1.age }.all()
                }
            } catch {
                
            }
        }
    }
    
    func testPerformanceNoUseFetchObject() {
        measureBlock { () -> Void in
            do {
                for _ in 0..<1000 {
                    let fetchRequest = NSFetchRequest(entityName: "PersonEntity")
                    fetchRequest.predicate = NSPredicate(format: "name != %@", "John")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "age", ascending: false)]
                    try self.context.executeFetchRequest(fetchRequest) as? [Person] ?? []
                }
            } catch {
                
            }
        }
    }
}
