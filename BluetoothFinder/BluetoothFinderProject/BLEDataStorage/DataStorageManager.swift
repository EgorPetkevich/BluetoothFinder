//
//  DataStorageManager.swift
//  blekokofinder
//
//  Created by George Popkich on 2.07.25.
//

import Foundation
import CoreData

public struct DataStorageManager {
    public static let shared = DataStorageManager()

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BLEDataBase")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
