//
//  ResultsController.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData


#if IOS
import UIKit

// MARK: NSFetchedResultsController

public class ResultsController<T: NSManagedObject> {
    internal let fetchedResultsController: NSFetchedResultsController
    internal let context: NSManagedObjectContext
    
    internal init(fetchRequest: NSFetchRequest, context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName: String?) {
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        self.context = context
    }
    
    public weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedResultsController.delegate = delegate
            do {
                try fetchedResultsController.performFetch()
            } catch _ {
            }
        }
    }
    
    public func sections() -> [SectionInfo<T>] {
        return fetchedResultsController.sections?.map{ SectionInfo<T>(sectionInfo: $0) } ?? []
    }
    
    public func numberOfSection() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    public func numberOfObjects(section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    public func containsIndexPath(indexPath: NSIndexPath) -> Bool {
        if indexPath.section >= numberOfSection() {
            return false
        } else if indexPath.row >= numberOfObjects(indexPath.section) {
            return false
        }
        return true
    }
    
    public func objectAtIndexPath(indexPath: NSIndexPath) -> T {
        return fetchedResultsController.objectAtIndexPath(indexPath) as! T
    }
    
    public func indexPathForObject(object: T) -> NSIndexPath? {
        return fetchedResultsController.indexPathForObject(object)
    }
}

// MARK: NSFetchedResultsSectionInfo
public class SectionInfo<T: NSManagedObject> {
    private let sectionInfo: NSFetchedResultsSectionInfo
    
    private init(sectionInfo: NSFetchedResultsSectionInfo) {
        self.sectionInfo = sectionInfo
    }
    
    public var name: String? {
        get {
            return sectionInfo.name
        }
    }
    
    public var indexTitle: String? {
        get {
            return sectionInfo.indexTitle
        }
    }
    
    public var numberOfObjects: Int {
        get {
            return sectionInfo.numberOfObjects
        }
    }
    
    public var objects: [T] {
        get {
            return sectionInfo.objects as? [T] ?? []
        }
    }
}

public extension Fetch {
    public func resultsController(sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> ResultsController<T> {
        return ResultsController(fetchRequest: self.fetchRequest(), context: self.context, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
    }
}
#endif
