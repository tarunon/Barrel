//
//  BarrelRealmTests.swift
//  BarrelRealmTests
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import XCTest
import Barrel
import RealmSwift
@testable import Barrel_Realm

class BarrelRealmTests: XCTestCase {
    
    var realm: Realm!
    
    override func setUp() {
        super.setUp()
        
        Barrel.debugMode = true
        
        do {
            if let path = Realm.Configuration.defaultConfiguration.path {
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                }
            }
            try realm = Realm()
            try realm.write {
                let sun = Star.insert(self.realm)
                sun.name = "Sun"
                sun.diameter = 1392000
                let mercury = Planet.insert(self.realm)
                mercury.name = "Mercury"
                mercury.diameter = 4879.4
                mercury.semiMajorAxis = 57910000
                mercury.parent = sun
                let venus = Planet.insert(self.realm)
                venus.name = "Venus"
                venus.diameter = 12103.6
                venus.semiMajorAxis = 108208930
                venus.parent = sun
                let earth = Planet.insert(self.realm)
                earth.name = "Earth"
                earth.diameter = 12756.274
                earth.semiMajorAxis = 149597870
                earth.parent = sun
                let moon = Satellite.insert(self.realm)
                moon.name = "Moon"
                moon.diameter = 3471.3
                moon.semiMajorAxis = 384400
                moon.parent = earth
                let mars = Planet.insert(self.realm)
                mars.name = "Mars"
                mars.diameter = 6794.4
                mars.semiMajorAxis = 227936640
                mars.parent = sun
                let jupiter = Planet.insert(self.realm)
                jupiter.name = "Jupiter"
                jupiter.diameter = 69911
                jupiter.semiMajorAxis = 778412010
                jupiter.parent = sun
            }
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFilter() {
        let sun = Star.objects(self.realm).brl_filter { $0.name == "Sun" }[0]
        XCTAssertEqual(sun.name, "Sun")
        let planets = Planet.objects(self.realm).brl_filter { $0.parent == sun }
        XCTAssertEqual(planets.underestimateCount(), 5)
        let moon = Satellite.objects(self.realm).brl_filter { $0.parent.name == "Earth" }[0]
        XCTAssertEqual(moon.name, "Moon")
        let opp = Planet.objects(self.realm).brl_filter { $0.parent.isNotNull() }
        print(opp.map { $0.name })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
