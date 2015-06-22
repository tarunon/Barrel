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
    var storeURL = NSURL(fileURLWithPath: "test.db")
    
    override func setUp() {
        super.setUp()
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle(forClass: self.classForCoder).URLForResource("Person", withExtension: "momd")!)!)
        try! context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL , options: nil)
        let datas: [[String: AnyObject]] = [["name": "John", "age": 18], ["name": "John", "age": 25], ["name": "Harry", "age": 39]]
        for data in datas {
            context.insert(Person).setKeyedValues(data).insert()
        }
        try! context.save()
    }
    
    override func tearDown() {
        try! context.save()
        try! NSFileManager.defaultManager().removeItemAtURL(storeURL)
        super.tearDown()
    }
    
    func testFetchAggregate() {
        let maxs = try! context.fetch(Person).aggregate{ $0.max($1.age) }.aggregate({ $1.name }).all()
        for max in maxs {
            XCTAssertEqual(max["max_age"] as! Int, 39, "Pass")
        }
    }
    
    func testFetchGroupBy() {
        let maxs = try! context.fetch(Person).aggregate{ $0.max($1.age) }.aggregate({ $1.name }).groupBy{ $0.name }.all()
        XCTAssertEqual(maxs.count, 2, "Pass")
    }
    
    func testFetchHaving() {
        let maxs = try! context.fetch(Person).aggregate{ $0.max($1.age) }.aggregate({ $1.name }).groupBy{ $0.name }.having{ $0.age > 30 }.all()
        XCTAssertEqual(maxs.count, 1, "Pass")
    }
}
