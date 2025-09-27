//
//  SearchMovieList.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 26.09.2025.
//

struct SearchMovieList: Hashable {
    let page: Int
    let movies: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    init(dto: SearchMovieListDTO) {
        self.page = dto.page
        self.movies = dto.results.map { $0.domain() }
        self.totalPages = dto.total_pages
        self.totalResults = dto.total_results
    }
}
