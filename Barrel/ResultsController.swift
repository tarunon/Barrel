//
//  ResultsController.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/05/24.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

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
            fetchedResultsController.performFetch(nil)
        }
    }
    
    public func sections() -> [SectionInfo<T>] {
        return (fetchedResultsController.sections as? [NSFetchedResultsSectionInfo])?.map({ SectionInfo<T>(sectionInfo: $0) }) ?? []
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
    
    public var indexTitle: String {
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
            return sectionInfo.objects as! [T]
        }
    }
}
