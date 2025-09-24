//
//  MoviesUseCase.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import Combine

protocol MoviesRepository {
    func topRated(language: String, page: Int, region: String) -> AnyPublisher<TopRatedList, APIError>
}

final class MoviesRepositoryImpl: MoviesRepository {
    // MARK: Private
    private let apiRequestService: APIRequestServiceProtocol
    
    // MARK: Init
    init(apiRequestService: APIRequestServiceProtocol = APIRequestService()) {
        self.apiRequestService = apiRequestService
    }
    
    // MARK: Protocol
    func topRated(language: String, page: Int, region: String) -> AnyPublisher<TopRatedList, APIError> {
        let endpoint = MoviesAPI.topRated(lanuguage: language, page: page, region: region)
        let request = NetworkRequest(request: endpoint, dto: TopRatedListDTO.self)
        
        return apiRequestService.publisher(request: request, callbackQueue: .global(qos: .utility))
            .map { $0.domain() }
            .eraseToAnyPublisher()
    }
}
