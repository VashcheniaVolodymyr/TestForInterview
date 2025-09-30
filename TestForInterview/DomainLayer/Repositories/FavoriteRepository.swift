//
//  FavoriteRepository.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 27.09.2025.
//

import CoreData

protocol FavoriteRepository {
    @discardableResult
    func addFavorite<Item: Favorable>(_ favorable: Item) -> Result<Void, AppError>
    func removeFavorite<Item: Favorable>(_ favorable: Item)
    func isFavorite<Item: Favorable>(_ favorable: Item) -> Bool
}

final class FavoriteRepositoryImpl: FavoriteRepository {
    @discardableResult
    func addFavorite<Item: Favorable>(_ favorable: Item) -> Result<Void, AppError> {
        if feach(favorable: favorable).isNil {
            return FavoriteCD(favorable: favorable).save()
        } else {
            return .failure(.coreDataError(.custom("Favorite with id \(favorable.favoralId) already exist")))
        }
    }
    
    func removeFavorite<Item: Favorable>(_ favorable: Item) {
        if let favorite = feach(favorable: favorable) {
            return favorite.delete()
        }
    }
    
    func isFavorite<Item: Favorable>(_ favorable: Item) -> Bool {
        if feach(favorable: favorable).notNil {
            return true
        } else {
            return false
        }
    }
    
    private func feach<Item: Favorable>(favorable: Item) -> FavoriteCD? {
        let fetchRequest: NSFetchRequest<FavoriteCD> = FavoriteCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "favoriteId == %@", favorable.favoralId)
        fetchRequest.fetchLimit = 1
        
        do {
            if let favorite = try CoreDataStack.viewContext.fetch(fetchRequest).first {
                return favorite
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
