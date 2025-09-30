//
//  FavoriteCD+CoreDataClass.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 29.09.2025.
//
//

import Foundation
import CoreData

@objc(FavoriteCD)
public class FavoriteCD: NSManagedObject {
    convenience init<Item: Favorable>(favorable: Item) {
        self.init(context: CoreDataStack.viewContext)
        self.favoriteId = favorable.favoralId
    }
}
