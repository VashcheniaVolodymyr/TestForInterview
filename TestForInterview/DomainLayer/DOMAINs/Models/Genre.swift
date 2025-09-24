//
//  Genre.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct Genre: Hashable {
    let id: Int
    let name: String
    
    init(dto: GenreDTO) {
        self.id = dto.id
        self.name = dto.name
    }
}
