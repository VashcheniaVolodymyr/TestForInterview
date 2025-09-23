//
//  ApiError.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

import Foundation

public enum APIError: Error {
    case buildRequest(APIBuildRequestError)
    case response(APIResponseError)
    case undefined(request: URLRequest?, error: any Error)
}

public enum APIBuildRequestError: Error {
    case invalidURL
}

public enum APIResponseError: Error {
    case noResponse
    case clientError(statusCode: Int, data: Data)
    case decodingError(Error)
}

// MARK: ClientPresentableError extensions
extension APIError: ClientPresentableError {
    public var clientMessage: String {
        switch self {
        case .buildRequest(let aPIBuildRequestError):
            return aPIBuildRequestError.clientMessage
        case .response(let aPIResponseError):
            return aPIResponseError.clientMessage
        case .undefined(_, let error):
            return error.localizedDescription
        }
    }
}


extension APIBuildRequestError: ClientPresentableError {
    public var clientMessage: String {
        switch self {
        case .invalidURL:
            return AppConstants.ApiClientError.invalidURL
        }
    }
}

extension APIResponseError: ClientPresentableError {
    public var clientMessage: String {
        return AppConstants.ApiClientError.somethingWhentWrong
    }
}
