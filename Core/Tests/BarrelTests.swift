//
//  BarrelTests.swift
//  BarrelTests
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import XCTest
import Barrel

struct TestModel: SelfExpression {
    var text: String = ""
    var number: Int = 0
    var array: [Int]
    var option: Int?
}

struct Many<T: ExpressionType>: ManyType {
    typealias ValueType = [T]
    typealias ElementType = T
}

extension AttributeType where ValueType == TestModel {
    var text: Attribute<String> { return attribute() }
    var number: Attribute<Int> { return attribute() }
    var array: Attribute<Many<Int>> { return attribute() }
    var option: Attribute<Optional<Int>> { return attribute() }
}

class BarrelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExpression() {
        let attribute = Attribute<TestModel>()
        
        let addToExpression = attribute.number + 1
        XCTAssertEqual(addToExpression.value, NSExpression(forFunction: "add:to:", arguments: [NSExpression(forKeyPath: "number"), NSExpression(forConstantValue: 1)]))
        
        let fromSubtractExpression = attribute.number - 2
        XCTAssertEqual(fromSubtractExpression.value, NSExpression(forFunction: "from:subtract:", arguments: [NSExpression(forKeyPath: "number"), NSExpression(forConstantValue: 2)]))
        
        let multiplyByExpression = attribute.number * 3
        XCTAssertEqual(multiplyByExpression.value, NSExpression(forFunction: "multiply:by:", arguments: [NSExpression(forKeyPath: "number"), NSExpression(forConstantValue: 3)]))
        
        let divideByExpression = attribute.number / 4
        XCTAssertEqual(divideByExpression.value, NSExpression(forFunction: "divide:by:", arguments: [NSExpression(forKeyPath: "number"), NSExpression(forConstantValue: 4)]))
        
        let maxExpression = attribute.number.max()
        XCTAssertEqual(maxExpression.value, NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "number")]))
        
        let minExpression = attribute.number.min()
        XCTAssertEqual(minExpression.value, NSExpression(forFunction: "min:", arguments: [NSExpression(forKeyPath: "number")]))
        
        let sumExpression = attribute.number.sum()
        XCTAssertEqual(sumExpression.value, NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "number")]))
        
        let averageExpression = attribute.number.average()
        XCTAssertEqual(averageExpression.value, NSExpression(forFunction: "average:", arguments: [NSExpression(forKeyPath: "number")]))
        
        let countExpression = attribute.array.count()
        XCTAssertEqual(countExpression.value, NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "array")]))
    }
    
    func testPredicate() {
        let attribute = Attribute<TestModel>()
        
        let equalToPredicate = attribute.text == "TEST"
        XCTAssertEqual(equalToPredicate.value, NSPredicate(format: "text == %@", "TEST"))
        
        let graterThanPredicate = attribute.number > 0
        XCTAssertEqual(graterThanPredicate.value, NSPredicate(format: "number > %i", 0))
        
        let graterThanOrEqualToPredicate = attribute.number >= 1
        XCTAssertEqual(graterThanOrEqualToPredicate.value, NSPredicate(format: "number >= %i", 1))
        
        let lessThanPredicate = attribute.number < 10
        XCTAssertEqual(lessThanPredicate.value, NSPredicate(format: "number < %i", 10))
        
        let lessThanOrEqualToPredicate = attribute.number <= 9
        XCTAssertEqual(lessThanOrEqualToPredicate.value, NSPredicate(format: "number <= %i", 9))
        
        let notEqualToPredicate = attribute.text != "TEST"
        XCTAssertEqual(notEqualToPredicate.value, NSPredicate(format: "text != %@", "TEST"))
        
        let betweenPredicate = attribute.number << (0..<9)
        XCTAssertEqual(betweenPredicate.value, NSPredicate(format: "number BETWEEN %@", [0, 9]))
        
        let inPredicate = attribute.text << ["A", "B", "C"]
        XCTAssertEqual(inPredicate.value, NSPredicate(format: "text IN %@", ["A", "B", "C"]))
        
        let contaiPredicate = attribute.text.contains("AAA")
        XCTAssertEqual(contaiPredicate.value, NSPredicate(format: "text CONTAINS %@", "AAA"))
        
        let begiWithPredicate = attribute.text.beginsWith("ABC")
        XCTAssertEqual(begiWithPredicate.value, NSPredicate(format: "text BEGINSWITH %@", "ABC"))
        
        let endsWithPredicate = attribute.text.endsWith("XYZ")
        XCTAssertEqual(endsWithPredicate.value, NSPredicate(format: "text ENDSWITH %@", "XYZ"))
        
        let likePredicate = attribute.text.like("BBB")
        XCTAssertEqual(likePredicate.value, NSPredicate(format: "text LIKE %@", "BBB"))
        
        let matchesPredicate = attribute.text.matches("^ABC.*XYZ$")
        XCTAssertEqual(matchesPredicate.value, NSPredicate(format: "text MATCHES %@", "^ABC.*XYZ$"))
        
        let anyPredicate = attribute.array.any { $0 > 0 }
        XCTAssertEqual(anyPredicate.value, NSPredicate(format: "ANY array > %i", 0))
        
        let allPredicate = attribute.array.all { $0 < 0 }
        XCTAssertEqual(allPredicate.value, NSPredicate(format: "ALL array < %i", 0))
        
        let isNullPredicate = attribute.option.isNull()
        XCTAssertEqual(isNullPredicate.value, NSPredicate(format: "option == nil"))

        let isNotNullPredicate = attribute.option.isNotNull()
        XCTAssertEqual(isNotNullPredicate.value, NSPredicate(format: "option != nil"))

        
        let andPredicate = equalToPredicate && allPredicate
        XCTAssertEqual(andPredicate.value, NSPredicate(format: "text == %@ AND ALL array < %i", "TEST", 0))
        
        let orPredicate = notEqualToPredicate || graterThanPredicate
        XCTAssertEqual(orPredicate.value, NSPredicate(format: "text != %@ OR number > %i", "TEST", 0))
        
        let notPredicate = !likePredicate
        XCTAssertEqual(notPredicate.value, NSPredicate(format: "NOT text LIKE %@", "BBB"))
    }
    
    func testSortDescriptors() {
        let attribute = Attribute<TestModel>()
        let sortAttr = Attribute<TestModel>(name: "sort")
        
        let ascendingSortDescriptors: SortDescriptors = (attribute.number < sortAttr.number)
        let ascendingSortDescriptors2: SortDescriptors = (sortAttr.number > attribute.number)
        let ascendingSortDescriptors3: SortDescriptors = (attribute.option < sortAttr.option)
        XCTAssertEqual(ascendingSortDescriptors.value, [NSSortDescriptor(key: "number", ascending: true)])
        XCTAssertEqual(ascendingSortDescriptors2.value, [NSSortDescriptor(key: "number", ascending: true)])
        XCTAssertEqual(ascendingSortDescriptors3.value, [NSSortDescriptor(key: "option", ascending: true)])
        
        let descendingSortDescriptors: SortDescriptors = (attribute.number > sortAttr.number)
        let descendingSortDescriptors2: SortDescriptors = (sortAttr.number < attribute.number)
        let descendingSortDescriptors3: SortDescriptors = (attribute.option > sortAttr.option)
        XCTAssertEqual(descendingSortDescriptors.value, [NSSortDescriptor(key: "number", ascending: false)])
        XCTAssertEqual(descendingSortDescriptors2.value, [NSSortDescriptor(key: "number", ascending: false)])
        XCTAssertEqual(descendingSortDescriptors3.value, [NSSortDescriptor(key: "option", ascending: false)])
    }
}
