//
//  HardwareProvider.swift
//  AppleDB
//
//  Created by Kane Parkinson on 31/07/2024.
//

import Foundation
import CoreData

final class HardwareProvider {
    static let shared = HardwareProvider()
    
    private let persistentContainer: NSPersistentCloudKitContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var newContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return context
    }
    
    private init() {
        persistentContainer = NSPersistentCloudKitContainer(name: "HardwareDataModel")
        
        // Set the store description to use the App Group directory
        guard let description = persistentContainer.persistentStoreDescriptions.first else {
            fatalError("No container description available")
        }

        // Define App Group identifier
        let appGroupIdentifier = "group.com.hydrate.AppleDB"
        
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let storeURL = appGroupURL.appendingPathComponent("HardwareDataModel.sqlite")
            description.url = storeURL
        }
        
        // CloudKit settings remain the same
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.hydrate.AppleDB.Hardware")
        
        // Update the persistent store descriptions
        persistentContainer.persistentStoreDescriptions = [description]
        
        // Enable automatic merging
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        // Load the persistent stores
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load store with error: \(error)")
            }
        }
    }
}
