//
//  NSManagedObject+Extensions.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 29.09.2025.
//

import CoreData
import Foundation

extension NSManagedObject {
    @discardableResult
    func save(context: NSManagedObjectContext = CoreDataStack.viewContext) -> Result<Void, AppError> {
        guard context.hasChanges else {
            return .failure(.coreDataError(.trySaveWhenHasNotChanges))
        }
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(.coreDataError(.undefined(error)))
        }
    }

    func delete(context: NSManagedObjectContext = CoreDataStack.viewContext) {
        context.delete(self)
        save(context: context)
    }
}
