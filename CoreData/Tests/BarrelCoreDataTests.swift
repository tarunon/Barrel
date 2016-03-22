//
//  BarrelCoreDataTests.swift
//  BarrelCoreDataTests
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import XCTest
import CoreData
import Barrel
import Barrel_CoreData

var token1: dispatch_once_t = 0
var token2: dispatch_once_t = 0


class BarrelCoreDataTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var storeDir = NSURL(fileURLWithPath: "test")
    var storeURL: NSURL {
        return self.storeDir.URLByAppendingPathComponent("test.db")
    }
    
    override func setUp() {
        super.setUp()

        Barrel.debugMode = true

        dispatch_once(&token1) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(self.storeDir, withIntermediateDirectories: false, attributes: nil)
            } catch {
            }
            do {
                try NSFileManager.defaultManager().removeItemAtURL(self.storeURL)
            } catch {
            }
        }

        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle(forClass: self.classForCoder).URLForResource("SolerSystem", withExtension: "momd")!)!)
        
        try! self.context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:self.storeURL , options: nil)
        dispatch_once(&token2) {
            let sun = Star.insert(self.context)
            sun.name = "Sun"
            sun.diameter = 1392000
            let mercury = Planet.insert(self.context)
            mercury.name = "Mercury"
            mercury.diameter = 4879.4
            mercury.semiMajorAxis = 57910000
            mercury.parent = sun
            let venus = Planet.insert(self.context)
            venus.name = "Venus"
            venus.diameter = 12103.6
            venus.semiMajorAxis = 108208930
            venus.parent = sun
            let earth = Planet.insert(self.context)
            earth.name = "Earth"
            earth.diameter = 12756.274
            earth.semiMajorAxis = 149597870
            earth.parent = sun
            let moon = Satellite.insert(self.context)
            moon.name = "Moon"
            moon.diameter = 3471.3
            moon.semiMajorAxis = 384400
            moon.parent = earth
            let mars = Planet.insert(self.context)
            mars.name = "Mars"
            mars.diameter = 6794.4
            mars.semiMajorAxis = 227936640
            mars.parent = sun
            let jupiter = Planet.insert(self.context)
            jupiter.name = "Jupiter"
            jupiter.diameter = 142984
            jupiter.semiMajorAxis = 778412010
            jupiter.parent = sun
            let io = Satellite.insert(self.context)
            io.name = "Io"
            io.diameter = 3643
            io.semiMajorAxis = 421700
            io.parent = jupiter
            let europa = Satellite.insert(self.context)
            europa.name = "Europa"
            europa.diameter = 3122
            europa.semiMajorAxis = 671034
            europa.parent = jupiter
            let ganymede = Satellite.insert(self.context)
            ganymede.name = "Ganymede"
            ganymede.diameter = 5262
            ganymede.semiMajorAxis = 1070412
            ganymede.parent = jupiter
            let callisto = Satellite.insert(self.context)
            callisto.name = "Callisto"
            callisto.diameter = 4821
            callisto.semiMajorAxis = 1882709
            callisto.parent = jupiter
            let saturn = Planet.insert(self.context)
            saturn.name = "Saturn"
            saturn.diameter = 120536
            saturn.semiMajorAxis = 1426725400
            saturn.parent = sun
            try! self.context.save()
        }
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetch() {
        let sun = Star.objects(self.context).brl_filter { $0.name == "Sun" }[0]
        XCTAssertEqual(sun.name, "Sun")
        
        let planets = Planet.objects(self.context).brl_filter { $0.parent == sun }
        XCTAssertEqual(planets.underestimateCount(), 6)
        XCTAssertEqual(planets.brl_sorted { $0.semiMajorAxis < $1.semiMajorAxis }.map { $0.name }, ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn"])
        
        let jupitersSatellites = Satellite.objects(self.context).brl_filter { $0.parent.name == "Jupiter" }
        XCTAssertEqual(jupitersSatellites.underestimateCount(), 4)
        
        let biggestPlanet = Planet.objects(self.context).brl_sorted { $0.diameter > $1.diameter }[0]
        XCTAssertEqual(biggestPlanet.name, "Jupiter")
        
        let sun2 = Star.objects(self.context).brl_filter { $0.children.any { $0.name == "Earth" } }[0]
        XCTAssertEqual(sun, sun2)
    }
    
    func testSequenceExtensions() {
        let fetch = Planet.objects(self.context).brl_sorted { $0.semiMajorAxis < $1.semiMajorAxis }
        XCTAssertEqual(fetch.underestimateCount(), 6)
        
        XCTAssertEqual(fetch.map { $0.name }[0], "Mercury")
        XCTAssertEqual(fetch.filter { $0.diameter > 100000 }.count, 2)
        var i = 0
        fetch.forEach {
            i += 1
            XCTAssert($0.isKindOfClass(Planet.self))
        }
        XCTAssertEqual(i, 6)
        XCTAssertEqual(fetch.dropFirst(2).first?.name, "Earth")
        XCTAssertNotEqual(fetch.dropFirst(3).first?.name, "Earth")
        XCTAssertEqual(fetch.dropLast(2).last?.name, "Mars")
        XCTAssertNotEqual(fetch.dropLast(3).last?.name, "Mars")
        XCTAssertEqual(fetch.prefix(4).last?.name, "Mars")
        XCTAssertNotEqual(fetch.prefix(5).last?.name, "Mars")
        XCTAssertEqual(fetch.suffix(4).first?.name, "Earth")
        XCTAssertNotEqual(fetch.suffix(5).first?.name, "Earth")
        XCTAssertEqual(fetch.split(100, allowEmptySlices: true) { $0.children.count > 0 }.count, 3)
    }
    
    func testAggregate() {
        let planetCount = Planet.objects(self.context).brl_aggregate { $0.name.count() }[0]["count:(name)"] as? Int
        XCTAssertEqual(planetCount, 6)
        let maxDiameter = Planet.objects(self.context).brl_aggregate { $0.diameter.max() }[0]["max:(diameter)"] as? Double
        XCTAssertEqual(maxDiameter, 142984)
        let groupedMinSemiMajorAxis = Satellite.objects(self.context).brl_aggregate { $0.semiMajorAxis.min() }.brl_aggregate { $0.parent.name }.brl_groupBy { $0.parent.name }
        XCTAssertEqual(groupedMinSemiMajorAxis.underestimateCount(), 2)
        groupedMinSemiMajorAxis.forEach {
            if let parentName = $0["parent.name"] as? String {
                switch parentName {
                case "Earth":
                    XCTAssertEqual($0["min:(semiMajorAxis)"] as? Double, 384400)
                case "Jupiter":
                    XCTAssertEqual($0["min:(semiMajorAxis)"] as? Double, 421700)
                default:
                    break
                }
            }
        }
    }
}
