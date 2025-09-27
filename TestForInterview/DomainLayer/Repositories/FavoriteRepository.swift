//
//  FavoriteRepository.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 27.09.2025.
//

protocol FavoriteRepository {
    func addFavorite<Item: Favorable>(_ favorite: Item) -> Set<Item>
    func removeFavorite<Item: Favorable>(_ favorite: Item) -> Set<Item>
    func isFavorite<Item: Favorable>(_ favorite: Item) -> Bool
}

final class FavoriteRepositoryImpl: FavoriteRepository {
    func addFavorite<Item: Favorable>(_ favorite: Item) -> Set<Item> {
        return Set()
    }
    
    func removeFavorite<Item: Favorable>(_ favorite: Item) -> Set<Item> {
        return Set()
    }
    
    func isFavorite<Item: Favorable>(_ favorite: Item) -> Bool {
        return false
    }
}
