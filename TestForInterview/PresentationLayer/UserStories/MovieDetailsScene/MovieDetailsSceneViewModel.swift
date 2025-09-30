//
//  MovieDetailsSceneViewModel.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import Foundation

enum MovieDetailsSceneState: Hashable {
    case initial
    case error(String)
    case loading
    case loaded
    
    static func ==(lhs: MovieDetailsSceneState, rhs: MovieDetailsSceneState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case (.error(let lhsMsg), .error(let rhsMsg)): return lhsMsg == rhsMsg
        case (.loading, .loading), (.loaded, .loaded): return true
        default: return false
        }
    }
}

protocol MovieDetailsSceneVMP: ObservableObject {
    var title: String { get }
    var posterURL: URL? { get }
    var voteAverage: String { get }
    var overview: String { get }
    var releaseDate: String { get }
    var state: MovieDetailsSceneState { get }
    var appButtonConfig: AppButton.Config { get }
    func onAppear()
}

final class MovieDetailsSceneViewModel: MovieDetailsSceneVMP {
    // MARK: Public
    @Published var title: String = ""
    @Published var posterURL: URL?
    @Published var voteAverage: String = ""
    @Published var overview: String = ""
    @Published var releaseDate: String = ""
    @Published var state: MovieDetailsSceneState = .initial
    @Published var appButtonConfig: AppButton.Config = .empty
    
    // MARK: Private
    private let movieId: Int32
    private let movieRepository: MoviesRepository
    private let favoriteRepository: FavoriteRepository
    
    // MARK: Initialization
    init(
        movieId: Int32,
        movieRepository: MoviesRepository = MoviesRepositoryImpl(),
        favoriteRepository: FavoriteRepository = FavoriteRepositoryImpl()
    ) {
        self.movieId = movieId
        self.movieRepository = movieRepository
        self.favoriteRepository = favoriteRepository
    }
    
    // MARK: Lifecycle
    func onAppear() {
        loadDetails()
    }
    
    // MARK: Private methods
    private func loadDetails() {
        self.state = .loading
        
        movieRepository.movieDetails(movieId: movieId, language: Locale.current.identifier)
            .subscribe(on: DispatchQueue.global(qos: .utility))
            .receive(on: DispatchQueue.main)
            .sinkAsync(
                receiveCompletion: { [weak self] status in
                    switch status {
                    case .finished:
                        break
                    case .failure(let failure):
                        self?.state = .error(failure.clientMessage)
                    }
                }, receiveValue: { [weak self] details in
                    self?.setUpDetails(movieDetails: details)
                    self?.state = .loaded
                }
            )
    }
    
    private func setUpDetails(movieDetails: MovieDetails) {
        self.title = movieDetails.title
        self.voteAverage = String(format: NSLocalizedString("rating", comment: ""), movieDetails.voteAverage.description)
        self.overview = movieDetails.overview
        self.releaseDate = movieDetails.formattedReleaseDate()
        
        DispatchQueue.main.async {
            self.posterURL = movieDetails.posterURL()
        }
        
        configureButton(movieDetails: movieDetails)
    }
    
    private func configureButton(movieDetails: MovieDetails) {
        let isFavorite = favoriteRepository.isFavorite(movieDetails)
        let title = isFavorite ? NSLocalizedString("remove_from_favorites", comment: "") : NSLocalizedString("add_to_favorites", comment: "")
        
        let action: VoidCallBack = {
            if isFavorite {
                self.favoriteRepository.removeFavorite(movieDetails)
            } else {
                self.favoriteRepository.addFavorite(movieDetails)
            }
            
            self.configureButton(movieDetails: movieDetails)
        }
        
        let style: AppButton.Style = isFavorite ? .secondary : .primary
        self.appButtonConfig = .init(title: title, style: style, action: action)
    }
}
