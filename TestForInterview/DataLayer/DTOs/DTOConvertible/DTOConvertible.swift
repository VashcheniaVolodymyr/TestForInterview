//
//  DTOConvertible.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

protocol DTOConvertible {
    associatedtype DTO
    func dto() -> DTO
}
