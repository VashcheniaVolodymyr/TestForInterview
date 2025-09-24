//
//  SpokenLanguage.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct SpokenLanguage: Hashable {
    let englishName: String
    let iso_639_1: String
    let name: String
    
    init(dto: SpokenLanguageDTO) {
        self.englishName = dto.english_name
        self.iso_639_1 = dto.iso_639_1
        self.name = dto.name
    }
}
