//
//  MovieDetailsSceneViewModel.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import Foundation

enum MovieDetailsSceneState {
    case initial
    case error(String)
    case loading
    case loaded
}

protocol MovieDetailsSceneVMP: ObservableObject {
    var title: String { get }
    var posterPath: String { get }
    var voteAverage: String { get }
    var overview: String { get }
    var releaseDate: String { get }
    var state: MovieDetailsSceneState { get }
}

final class MovieDetailsSceneViewModel: MovieDetailsSceneVMP {
    // MARK: Public
    @Published var title: String = ""
    @Published var posterPath: String = ""
    @Published var voteAverage: String = ""
    @Published var overview: String = ""
    @Published var releaseDate: String = ""
    @Published var state: MovieDetailsSceneState = .initial
    
    // MARK: Private
    private let movieId: Int32
    private let movieRepository: MoviesRepository
    
    // MARK: Initialization
    init(movieId: Int32, movieRepository: MoviesRepository = MoviesRepositoryImpl()) {
        self.movieId = movieId
        self.movieRepository = movieRepository
        
        loadDetails()
    }
    
    private func loadDetails() {
        self.state = .loading
        
        movieRepository.movieDetails(movieId: movieId, language: Locale.current.identifier)
            .subscribe(on: DispatchQueue.global(qos: .utility))
            .receive(on: DispatchQueue.main)
            .sinkAsync(
                receiveCompletion: { [weak self] status in
                    switch status {
                    case .finished:
                        self?.state = .loaded
                    case .failure(let failure):
                        self?.state = .error(failure.clientMessage)
                    }
                }, receiveValue: { [weak self] details in
                    self?.setUpDetails(movieDetails: details)
                }
            )
    }
    
    private func setUpDetails(movieDetails: MovieDetails) {
        self.title = movieDetails.title
        self.posterPath = movieDetails.posterPath
        self.voteAverage = movieDetails.voteAverage.description
        self.overview = movieDetails.overview
        self.releaseDate = movieDetails.releaseDate
    }
}
