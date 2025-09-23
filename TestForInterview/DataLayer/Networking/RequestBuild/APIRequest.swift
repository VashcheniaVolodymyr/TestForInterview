//
//  APIRequest.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

import Foundation

public typealias Parameters = [String: any Any & Sendable]

public protocol APIRequest: URLRequestConvertible {
    var baseURLString: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parametrs: Parameters? { get }
}

extension APIRequest {
    var baseURLString: String {
        return "https://"
    }
    
    var parametrs: Parameters? { return nil }
    var headers: [String: String]? { return nil }
    
    func body() throws -> Data? { return nil }
    
    func asURLRequest() throws -> URLRequest {
        let urlComponents = NSURLComponents(string: baseURLString + path)
        
        if let parametrsArray = parametrs, !parametrsArray.isEmpty {
            urlComponents?.queryItems = []
            
            for parametr in parametrsArray {
                let item = URLQueryItem(name: parametr.key, value: "\(parametr.value)")
                urlComponents?.queryItems?.append(item)
            }
        }
        
        guard let urlRequest = urlComponents?.url else {
            throw APIError.buildRequest(.invalidURL)
        }
        
        var request = try URLRequest(
            url: urlRequest,
            method: method,
            headers: headers
        )
        
        request.httpBody = try body()
    
        return request
    }
}
