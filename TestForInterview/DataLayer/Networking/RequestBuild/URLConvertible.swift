//
//  URLConvertible.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

import Foundation

public protocol URLConvertible: Sendable {
    func asURL() throws -> URL
}

extension URL: URLConvertible {
    public func asURL() throws -> URL { self }
}
