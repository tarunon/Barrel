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

    func testExample() {
        
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
