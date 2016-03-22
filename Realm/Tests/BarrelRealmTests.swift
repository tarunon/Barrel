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
import Barrel_Realm

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
                jupiter.diameter = 142984
                jupiter.semiMajorAxis = 778412010
                jupiter.parent = sun
                let io = Satellite.insert(self.realm)
                io.name = "Io"
                io.diameter = 3643
                io.semiMajorAxis = 421700
                io.parent = jupiter
                let europa = Satellite.insert(self.realm)
                europa.name = "Europa"
                europa.diameter = 3122
                europa.semiMajorAxis = 671034
                europa.parent = jupiter
                let ganymede = Satellite.insert(self.realm)
                ganymede.name = "Ganymede"
                ganymede.diameter = 5262
                ganymede.semiMajorAxis = 1070412
                ganymede.parent = jupiter
                let callisto = Satellite.insert(self.realm)
                callisto.name = "Callisto"
                callisto.diameter = 4821
                callisto.semiMajorAxis = 1882709
                callisto.parent = jupiter
                let saturn = Planet.insert(self.realm)
                saturn.name = "Saturn"
                saturn.diameter = 120536
                saturn.semiMajorAxis = 1426725400
                saturn.parent = sun
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
    
    func testExtensions() {
        let sun = Star.objects(self.realm).brl_filter { $0.name == "Sun" }[0]
        XCTAssertEqual(sun.name, "Sun")
        let planets = Planet.objects(self.realm).brl_filter { $0.parent == sun }
        XCTAssertEqual(planets.underestimateCount(), 6)
        XCTAssertEqual(planets.brl_sorted { $0.semiMajorAxis < $1.semiMajorAxis }.map { $0.name }, ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn"])
        let moon = Satellite.objects(self.realm).brl_filter { $0.parent.name == "Earth" }[0]
        XCTAssertEqual(moon.name, "Moon")
        let maxDiameter = Planet.objects(self.realm).brl_max { $0.diameter }
        XCTAssertEqual(maxDiameter, 142984)
        let minSemiMajorAxis = Satellite.objects(self.realm).brl_filter { $0.parent.name == "Jupiter" }.brl_min { $0.semiMajorAxis }
        XCTAssertEqual(minSemiMajorAxis, 421700)
    }
}
