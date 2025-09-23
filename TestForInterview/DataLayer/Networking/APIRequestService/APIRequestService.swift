//
//  NetworkRequestService.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

import Combine
import Foundation

protocol APIRequestServiceProtocol: AnyObject {
    func callBack<DTO: Responsable>(
        request: NetworkRequest<DTO>,
        callbackQueue: DispatchQueue,
        result: @escaping Callback<Result<DTO.DTO, APIError>>
    )
    
    func publisher<DTO: Responsable>(
        request: NetworkRequest<DTO>,
        callbackQueue: DispatchQueue
    ) -> AnyPublisher<DTO.DTO, APIError>
}

final class APIRequestService: APIRequestServiceProtocol {
    // MARK: Private
    private let networkService: NetworkService
        
    // MARK: Init
    init(networkService: NetworkService = BaseNetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: Protocol
    func publisher<DTO>(
        request: NetworkRequest<DTO>,
        callbackQueue: DispatchQueue
    ) -> AnyPublisher<DTO.DTO, APIError> where DTO : Responsable {
        return performRequest(request: request, callbackQueue: callbackQueue)
            .eraseToAnyPublisher()
    }
    
    func callBack<DTO: Responsable>(
        request: NetworkRequest<DTO>,
        callbackQueue: DispatchQueue,
        result: @escaping Callback<Result<DTO.DTO, APIError>>
    ) {
        performRequest(request: request, callbackQueue: callbackQueue)
            .sinkAsync(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        result(.failure(failure))
                    }
                }, receiveValue: { dto in
                    result(.success(dto))
                }
            )
    }
    
    // MARK: Private methods
    private func performRequest<DTO: Responsable>(
        request: NetworkRequest<DTO>,
        callbackQueue: DispatchQueue
    ) -> AnyPublisher<DTO.DTO, APIError> {
        return networkService.dataTaskPublisher(request.request, callbackQueue: callbackQueue)
            .map(\.data)
            .decode(type: request.dto, decoder: JSONDecoder())
            .map { $0.dto() }
            .mapError {
                if let apiError = $0 as? APIError {
                    return apiError
                } else {
                    return APIError.response(.decodingError($0))
                }
            }
            .eraseToAnyPublisher()
    }
}
