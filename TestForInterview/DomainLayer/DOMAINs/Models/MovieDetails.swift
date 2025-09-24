//
//  MovieDetails.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct MovieDetails: Hashable {
    let adult: Bool
    let backdropPath: String
    let belongsToCollection: String
    let budget: Int
    let genres: [Genre]
    let homepage: String
    let id: Int
    let imdbId: String
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String
    
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let releaseDate: String
    let revenue: Int
    let runtime: Int
    let spokenLanguages: [SpokenLanguage]
    
    let status: String
    let tagline: String
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    
    init(dto: MovieDetailsDTO) {
        self.adult = dto.adult
        self.backdropPath = dto.backdrop_path
        self.belongsToCollection = dto.belongs_to_collection
        self.budget = dto.budget
        self.genres = dto.genres.map { $0.domain() }
        self.homepage = dto.homepage
        self.id = dto.id
        self.imdbId = dto.imdb_id
        self.originalLanguage = dto.original_language
        self.originalTitle = dto.original_title
        self.overview = dto.overview
        self.popularity = dto.popularity
        self.posterPath = dto.poster_path
        self.productionCompanies = dto.production_companies.map { $0.domain() }
        self.productionCountries = dto.production_countries.map { $0.domain() }
        self.releaseDate = dto.release_date
        self.revenue = dto.revenue
        self.runtime = dto.runtime
        self.spokenLanguages = dto.spoken_languages.map { $0.domain() }
        self.status = dto.status
        self.tagline = dto.tagline
        self.title = dto.title
        self.video = dto.video
        self.voteAverage = dto.vote_average
        self.voteCount = dto.vote_count
    }
}
