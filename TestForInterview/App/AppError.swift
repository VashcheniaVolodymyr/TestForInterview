//
//  AppError.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 29.09.2025.
//

enum AppError: Error {
    case coreDataError(CoreDataError)
    case networkingError(APIError)
}

enum CoreDataError: Error {
    case trySaveWhenHasNotChanges
    case undefined(Error)
    case custom(String)
}
