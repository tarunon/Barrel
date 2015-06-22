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

    func testAttributeInFetch() {
        let personFetchRequest = context.fetch(Person).filter{ $0.name == "John" && $0.age == 20 }.orderBy{ $0.age < $1.age }.fetchRequest()
        XCTAssertNotNil(personFetchRequest.predicate, "Pass")
        XCTAssertEqual(personFetchRequest.predicate!, NSCompoundPredicate(type: .AndPredicateType, subpredicates: [NSPredicate(value: true), NSPredicate(format: "name == %@ && age == %i", "John", 20)]), "Pass")
        XCTAssertNotNil(personFetchRequest.sortDescriptors, "Pass")
        XCTAssertEqual(personFetchRequest.sortDescriptors as! [NSSortDescriptor], [NSSortDescriptor(key: "age", ascending: true)], "Pass")

        let staffFetchRequest = context.fetch(Staff).filter{ $0.name == "John" && $0.age == 20 }.orderBy{ $0.age < $1.age }.fetchRequest()
        XCTAssertNotNil(staffFetchRequest.predicate, "Pass")
        XCTAssertEqual(staffFetchRequest.predicate!, NSCompoundPredicate(type: .AndPredicateType, subpredicates: [NSPredicate(value: true), NSPredicate(format: "name == %@ && age == %i", "John", 20)]), "Pass")
        XCTAssertNotNil(staffFetchRequest.sortDescriptors, "Pass")
        XCTAssertEqual(staffFetchRequest.sortDescriptors as! [NSSortDescriptor], [NSSortDescriptor(key: "age", ascending: true)], "Pass")
        
        let managerFetchRequest = context.fetch(Staff).filter{ $0.post == "manager" }.fetchRequest()
        XCTAssertNotNil(managerFetchRequest.predicate, "Pass")
        XCTAssertEqual(managerFetchRequest.predicate!, NSCompoundPredicate(type: .AndPredicateType, subpredicates: [NSPredicate(value: true), NSPredicate(format: "post == %@", "manager")]), "Pass")

        let noChildrenFetchRequest = context.fetch(Person).filter{ $0.children == Set<Person>() }.fetchRequest()
        XCTAssertNotNil(noChildrenFetchRequest.predicate, "Pass")
        XCTAssertEqual(noChildrenFetchRequest.predicate!, NSCompoundPredicate(type: .AndPredicateType, subpredicates: [NSPredicate(value: true), NSPredicate(format: "children == %@", Set<Person>())]), "Pass")
        
        let aManager = context.insert(Staff).setValues{
            $0.name = "Stive"
            $0.age = 39
            $0.post = "president"
        }.insert()
        
        let subordinateFetchRequest = context.fetch(Staff).filter{ $0.chief == aManager }.fetchRequest()
        XCTAssertNotNil(subordinateFetchRequest.predicate, "Pass")
        XCTAssertEqual(subordinateFetchRequest.predicate!, NSCompoundPredicate(type: .AndPredicateType, subpredicates: [NSPredicate(value: true), NSPredicate(format: "chief == %@", aManager)]), "Pass")

// unsupported at swift 1.2
//        let noPostFetchRequest = context.fetch(Staff).filter{ $0.post == nil }.fetchRequest()
//        XCTAssertNotNil(noPostFetchRequest.predicate, "Pass")
//        XCTAssertEqual(noPostFetchRequest.predicate!, NSCompoundPredicate(type: .AndPredicateType, subpredicates: [NSPredicate(value: true), NSPredicate(format: "post == nil")]), "Pass")
        
    }
}
