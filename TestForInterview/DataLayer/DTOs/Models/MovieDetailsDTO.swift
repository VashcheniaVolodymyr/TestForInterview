//
//  MovieDetailsDTO.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct MovieDetailsDTO: Responsable, DTOConvertible, DOMAINConvertible {
    let adult: Bool
    let backdrop_path: String?
    let budget: Int
    let genres: [GenreDTO]
    let homepage: String
    let id: Int
    let imdb_id: String?
    let original_language: String
    let original_title: String
    let overview: String
    let popularity: Double
    let poster_path: String?
    
    let production_companies: [ProductionCompanyDTO]
    let production_countries: [ProductionCountryDTO]
    let release_date: String
    let revenue: Int
    let runtime: Int
    let spoken_languages: [SpokenLanguageDTO]
    
    let status: String
    let tagline: String
    let title: String
    let video: Bool
    let vote_average: Double
    let vote_count: Int
    
    func dto() -> Self {
        return self
    }
    
    func domain() -> MovieDetails {
        return MovieDetails(dto: dto())
    }
}
