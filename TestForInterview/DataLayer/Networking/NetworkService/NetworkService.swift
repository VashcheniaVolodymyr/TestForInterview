//
//  NetworkService.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

import Foundation
import Combine

public protocol NetworkService {
    func dataTaskPublisher(_ request: APIRequest, callbackQueue: DispatchQueue) -> AnyPublisher<URLRequest.Response, APIError>
}

public extension NetworkService {
    func dataTaskPublisher(_ request: APIRequest, callbackQueue: DispatchQueue = .main) -> AnyPublisher<URLRequest.Response, APIError> {
        dataTaskPublisher(request, callbackQueue: callbackQueue)
    }
}

public class BaseNetworkService: NetworkService {
    // MARK: Private
    private let session: URLSession

    // MARK: Init
    public init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }

    // MARK: Protocol
    public func dataTaskPublisher(
        _ request: APIRequest,
        callbackQueue: DispatchQueue
    ) -> AnyPublisher<URLRequest.Response, APIError> {
        do {
            let request = try request.asURLRequest()
            
            return session.dataTaskPublisher(for: request)
                .tryMap { result -> URLRequest.Response in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        throw APIError.response(.noResponse)
                    }
                    
                    if httpResponse.isResponseOK.NOT {
                        throw APIError.response(.clientError(statusCode: httpResponse.statusCode, data: result.data))
                    }
                    
                    return (result.data, httpResponse)
                }
                .mapError { $0.asAPIError(request: request) }
                .receive(on: callbackQueue)
                .eraseToAnyPublisher()
        } catch {
            return Fail(
                outputType: URLRequest.Response.self,
                failure: error.asApiError
            )
            .eraseToAnyPublisher()
        }
    }
}
