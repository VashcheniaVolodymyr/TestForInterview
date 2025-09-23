//
//   HTTPURLResponse+Extension.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

import Foundation

extension HTTPURLResponse {
    var isResponseOK: Bool {
        return (200..<299).contains(statusCode)
    }
}
