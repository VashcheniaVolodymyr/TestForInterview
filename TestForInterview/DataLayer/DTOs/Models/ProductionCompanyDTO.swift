//
//  ProductionCompanyDTO.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct ProductionCompanyDTO: Decodable, DOMAINConvertible {
    let id: Int
    let logPath: String
    let name: String
    let origin_country: String
    
    func domain() -> ProductionCompany {
        return ProductionCompany(dto: self)
    }
}
