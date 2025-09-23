//
//  URLRequest+Extensions.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

import Foundation

extension URLRequest {
    public typealias Response = (data: Data, response: HTTPURLResponse)
}

extension URLRequest {
    public init(url: any URLConvertible, method: HTTPMethod, headers: [String: String]? = nil) throws {
        let url = try url.asURL()

        self.init(url: url)

        httpMethod = method.rawValue
        allHTTPHeaderFields = headers
    }
}
