//
//  HardwareProvider.swift
//  AppleDBWatchApp
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
        
        guard let description = persistentContainer.persistentStoreDescriptions.first else {
            fatalError("No container description available")
        }

        let appGroupIdentifier = "group.com.hydrate.AppleDB"
        
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let storeURL = appGroupURL.appendingPathComponent("HardwareDataModel.sqlite")
            description.url = storeURL
            print(storeURL)
        }
        
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.hydrate.AppleDB.Hardware")
        
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load store with error: \(error)")
            }
        }
    }
}
