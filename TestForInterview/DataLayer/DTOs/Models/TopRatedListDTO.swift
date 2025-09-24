//
//  TopRatedListDTO.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct TopRatedListDTO: Responsable, DTOConvertible, DOMAINConvertible {
    let page: Int
    let results: [MovieDTO]
    let totalPages: Int
    let totalResults: Int
    
    func dto() -> Self {
        return self
    }
    
    func domain() -> TopRatedList {
        return TopRatedList(dto: dto())
    }
}
