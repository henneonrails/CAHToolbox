//
//  CoreDataStack.swift
//  Seewetter2
//
//  Created by Holger Haenisch on 19.10.15.
//  Copyright © 2015 Holger Hänisch. All rights reserved.
//

import CoreData

/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Singleton controller to manage the main Core Data stack for the application. It vends a persistent store coordinator, the managed object model, and a URL for the persistent store.
*/


class CoreDataStackManager {
    // MARK: Properties
    
    static let sharedManager = CoreDataStackManager()
    static let applicationDocumentsDirectoryName = "com.coding-at-home.seewetter"
    static let mainStoreFileName = "Seewetter.storedata"
    static let errorDomain = "CoreDataStackManager"
    
    /// The managed object model for the application.
    lazy var managedObjectModel: NSManagedObjectModel = {
        /*
        This property is not optional. It is a fatal error for the application
        not to be able to find and load its model.
        */
        let modelURL = NSBundle.mainBundle().URLForResource("Seewetter", withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    /// Primary persistent store coordinator for the application.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        /*
        This implementation creates and return a coordinator, having added the
        store for the application to it. (The directory for the store is created, if necessary.)
        */
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storeURL, options: options)
        }
        catch {
            fatalError("Could not add the persistent store: \(error).")
        }
        
        return persistentStoreCoordinator
        }()
    
    /// The directory the application uses to store the Core Data store file.
    lazy var applicationDocumentsDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        
        let applicationSupportDirectoryURL = urls.last!
        
        let applicationSupportDirectory = applicationSupportDirectoryURL.URLByAppendingPathComponent(applicationDocumentsDirectoryName)
        
        do {
            let properties = try applicationSupportDirectory.resourceValuesForKeys([NSURLIsDirectoryKey])
            if let isDirectory = properties[NSURLIsDirectoryKey] as? Bool where isDirectory == false {
                let description = NSLocalizedString("Could not access the application data folder.", comment: "Failed to initialize applicationSupportDirectory.")
                
                let reason = NSLocalizedString("Found a file in its place.", comment: "Failed to initialize applicationSupportDirectory.")
                
                throw NSError(domain: errorDomain, code: 201, userInfo: [
                    NSLocalizedDescriptionKey: description,
                    NSLocalizedFailureReasonErrorKey: reason
                    ])
            }
        }
        catch let error as NSError where error.code != NSFileReadNoSuchFileError {
            fatalError("Error occured: \(error).")
        }
        catch {
            let path = applicationSupportDirectory.path!
            
            do {
                try fileManager.createDirectoryAtPath(path, withIntermediateDirectories:true, attributes:nil)
            }
            catch {
                fatalError("Could not create application documents directory at \(path).")
            }
        }
        
        return applicationSupportDirectory
        }()
    
    /// URL for the main Core Data store file.
    lazy var storeURL: NSURL = {
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent(mainStoreFileName)
        }()
    
    /// the managedObjectContext
    lazy var managedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return moc
        }()
    
    /// a concurrencyType managedObjectContext for use in background operations on the database
    /// eg. cleanup normaly called: privateManagedObjectContext.performBlock
    lazy var privateManagedObjectContext : NSManagedObjectContext = {
        let pmoc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        pmoc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return pmoc
        }()

}