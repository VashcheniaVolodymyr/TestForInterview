//
//  SearchMovieListDTO.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 26.09.2025.
//

struct SearchMovieListDTO: Responsable, DTOConvertible, DOMAINConvertible {
    let page: Int
    let results: [MovieDTO]
    let total_pages: Int
    let total_results: Int
    
    func dto() -> Self {
        return self
    }
    
    func domain() -> SearchMovieList {
        return SearchMovieList(dto: dto())
    }
}
