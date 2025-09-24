//
//  ProductionCompany.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct ProductionCompany: Hashable {
    let id: Int
    let logPath: String
    let name: String
    let originCountry: String
    
    init(dto: ProductionCompanyDTO) {
        self.id = dto.id
        self.logPath = dto.logPath
        self.name = dto.name
        self.originCountry = dto.origin_country
    }
}
