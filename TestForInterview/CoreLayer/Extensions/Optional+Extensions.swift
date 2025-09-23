//
//  Optional+Extensions.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

extension Optional {
    var isNil: Bool {
        self == nil
    }
    
    var notNil: Bool {
        self != nil
    }
}
