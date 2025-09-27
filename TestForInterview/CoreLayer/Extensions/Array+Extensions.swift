//
//  Array+Extensions.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 27.09.2025.
//

extension Array {
    func uniqueBy<T: Hashable>(_ keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return self.filter { element in
            let value = element[keyPath: keyPath]
            return seen.insert(value).inserted
        }
    }
}

