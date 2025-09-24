//
//  ProductionCountry.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct ProductionCountry: Hashable {
    let iso_3166_1: String
    let name: String
    
    init(dto: ProductionCountryDTO) {
        self.iso_3166_1 = dto.iso_3166_1
        self.name = dto.name
    }
}
