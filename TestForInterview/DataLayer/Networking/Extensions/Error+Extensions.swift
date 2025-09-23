//
//  Error+Extensions.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

import Foundation

extension Error {
    func asAPIError(request: URLRequest) -> APIError {
        guard let apiError = self as? APIError else {
            return .undefined(request: request, error: self)
        }
        
        return apiError
    }
    
    var asApiError: APIError {
        guard let apiError = self as? APIError else {
            return .undefined(request: nil, error: self)
        }
        
        return apiError
    }
    
    var tryMapToApiError: APIError? {
        guard let apiError = self as? APIError else {
            return nil
        }
        
        return apiError
    }
}
