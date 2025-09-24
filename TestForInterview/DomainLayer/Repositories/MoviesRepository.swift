//
//  MoviesUseCase.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import Combine

protocol MoviesRepository {
    func topRated(language: String, page: Int32, region: String) -> AnyPublisher<TopRatedList, APIError>
    func movieDetails(movieId: Int32, language: String) -> AnyPublisher<MovieDetails, APIError>
}

final class MoviesRepositoryImpl: MoviesRepository {
    // MARK: Private
    private let apiRequestService: APIRequestServiceProtocol
    
    // MARK: Init
    init(apiRequestService: APIRequestServiceProtocol = APIRequestService()) {
        self.apiRequestService = apiRequestService
    }
    
    // MARK: Protocol
    func topRated(language: String, page: Int32, region: String) -> AnyPublisher<TopRatedList, APIError> {
        let endpoint = MoviesAPI.topRated(language: language, page: page, region: region)
        let request = NetworkRequest(request: endpoint, dto: TopRatedListDTO.self)
        
        return apiRequestService.publisher(request: request, callbackQueue: .global(qos: .utility))
            .map { $0.domain() }
            .eraseToAnyPublisher()
    }
    
    func movieDetails(movieId: Int32, language: String) -> AnyPublisher<MovieDetails, APIError> {
        let endpoint = MoviesAPI.movieDetails(movieId: movieId, language: language)
        let request = NetworkRequest(request: endpoint, dto: MovieDetailsDTO.self)
        
        return apiRequestService.publisher(request: request, callbackQueue: .global(qos: .utility))
            .map { $0.domain() }
            .eraseToAnyPublisher()
    }
}
