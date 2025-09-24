//
//  GenreDTO.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct GenreDTO: Decodable, DOMAINConvertible {
    let id: Int
    let name: String
    
    func domain() -> Genre {
        return Genre(dto: self)
    }
}
