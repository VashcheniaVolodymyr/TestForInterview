//
//  Data+Extensions.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 25.09.2025.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys, .fragmentsAllowed, .withoutEscapingSlashes]
              ),
              let prettyJSON = NSString(
                data: data,
                encoding: String.Encoding.utf8.rawValue
              ) else {
            return nil
        }
        
        return prettyJSON
    }
}
