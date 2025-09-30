//
//  AssignOwnership.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 26.09.2025.
//

import Combine

public enum ObjectOwnership {
    case strong
    case weak
    case unowned
}

public extension Publisher where Self.Failure == Never {
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>,
                                 on object: Root,
                                 ownership: ObjectOwnership = .strong) -> AnyCancellable {
        switch ownership {
        case .strong:
            return assign(to: keyPath, on: object)
        case .weak:
            return sink { [weak object] value in
                object?[keyPath: keyPath] = value
            }
        case .unowned:
            return sink { [unowned object] value in
                object[keyPath: keyPath] = value
            }
        }
    }
}
