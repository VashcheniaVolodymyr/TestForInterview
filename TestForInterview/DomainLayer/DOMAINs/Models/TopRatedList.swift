//
//  TopRatedList.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct TopRatedList: Hashable {
    let page: Int
    let movies: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    init(dto: TopRatedListDTO) {
        self.page = dto.page
        self.movies = dto.results.map { $0.domain() }
        self.totalPages = dto.totalPages
        self.totalResults = dto.totalResults
    }
}
