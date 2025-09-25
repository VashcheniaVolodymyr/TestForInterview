//
//  Date+Extensions.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 25.09.2025.
//

import Foundation

extension Date {
    static var shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static var longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
}
