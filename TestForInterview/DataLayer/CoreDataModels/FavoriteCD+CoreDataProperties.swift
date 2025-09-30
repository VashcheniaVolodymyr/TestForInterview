//
//  FavoriteCD+CoreDataProperties.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 29.09.2025.
//
//

import Foundation
import CoreData

extension FavoriteCD {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteCD> {
        return NSFetchRequest<FavoriteCD>(entityName: "FavoriteCD")
    }
    @NSManaged public var favoriteId: String
}

extension FavoriteCD: Identifiable {}
