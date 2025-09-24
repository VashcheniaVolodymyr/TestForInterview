//
//  SpokenLanguageDTO.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

struct SpokenLanguageDTO: Decodable, DOMAINConvertible {
    let english_name: String
    let iso_639_1: String
    let name: String
    
    func domain() -> SpokenLanguage {
        return SpokenLanguage(dto: self)
    }
}
