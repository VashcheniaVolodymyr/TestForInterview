//
//  Movie.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct Movie: Hashable {
    let adult: Bool
    let backdropPath: String
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String
    let releaseDate: String
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    
    init(dto: MovieDTO) {
        self.adult = dto.adult
        self.backdropPath = dto.backdrop_path
        self.genreIds = dto.genre_ids
        self.id = dto.id
        self.originalLanguage = dto.original_language
        self.originalTitle = dto.original_title
        self.overview = dto.overview
        self.popularity = dto.popularity
        self.posterPath = dto.poster_path
        self.releaseDate = dto.release_date
        self.title = dto.title
        self.video = dto.video
        self.voteAverage = dto.vote_average
        self.voteCount = dto.vote_count
    }
}
