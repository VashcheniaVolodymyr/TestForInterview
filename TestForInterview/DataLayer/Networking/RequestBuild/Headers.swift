//
//  Headers.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import Foundation

enum Headers {
    static let accept = "accept"
    static let applicationJson = "application/json"
    
    // MARK: Authorization
    static let authorization = "Authorization"
    static func bearer(token: String) -> String {
        return "Bearer " + token
    }
}
