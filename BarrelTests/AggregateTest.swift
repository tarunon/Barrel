//
//  AggregateTest.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/28.
//  Copyright (c) 2015 Nobuo Saito. All rights reserved.
//

import Foundation
import XCTest
import CoreData
import Barrel

class AggregateTest: XCTestCase {
    
    var context: NSManagedObjectContext!
    var storeURL = NSURL(fileURLWithPath: "test.db")!
    
    override func setUp() {
        super.setUp()
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle(forClass: self.classForCoder).URLForResource("Person", withExtension: "momd")!)!)
        context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL , options: nil, error: nil)
        let datas: [[String: AnyObject]] = [["name": "John", "age": 18], ["name": "John", "age": 25], ["name": "Harry", "age": 39]]
        for data in datas {
            context.insert(Person).setKeyedValues(data).insert()
        }
        context.save(nil)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
        super.tearDown()
    }
    
    func testFetchAggregate() {
        let maxs = context.fetch(Person).aggregate{ $0.max($1.age) }.aggregate({ $1.name }).execute().all()
        for max in maxs {
            XCTAssertEqual(max["maxAge"] as! Int, 39, "Pass")
        }
    }
    
    func testFetchGroupBy() {
        let maxs = context.fetch(Person).aggregate{ $0.max($1.age) }.aggregate({ $1.name }).groupBy("name").execute().all()
        XCTAssertEqual(maxs.count, 2, "Pass")
    }
    
    func testFetchHaving() {
        let maxs = context.fetch(Person).aggregate{ $0.max($1.age) }.aggregate({ $1.name }).groupBy("name").having{ $0.age > 30 }.execute().all()
        XCTAssertEqual(maxs.count, 1, "Pass")
    }
}
