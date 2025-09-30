//
//  CoreDataStack.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 29.09.2025.
//

import CoreData

struct CoreDataStack {
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TestForInterview")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Failed to load store: \(error)")
            }
        }
        return container
    }()

    static var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    static func backgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
}
