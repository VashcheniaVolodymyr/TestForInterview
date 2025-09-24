//
//  Injectable.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import Foundation

protocol Injectable {
    init()
}

@propertyWrapper
class Injected<T: Injectable> {
    private var depentencies = DependencyContainer.instanse
    
    var wrappedValue: T {
        get {
            if let exist = depentencies.pull(T.self) {
                return exist
            } else {
                let value = T()
                depentencies.enter(value)
                return value
            }
        }
        set {
            depentencies.enter(newValue)
        }
    }
}

fileprivate class DependencyContainer {
    static let instanse = DependencyContainer()
    private static var dependencies: [String: Any] = [:]
    
    private lazy var lock: NSLock = NSLock()
    
    func enter<T>(_ value: T) {
        lock.withLock {
            DependencyContainer.dependencies[String(describing: T.self)] = value
        }
    }
    
    func pull<T>(_ type: T.Type) -> T? {
        lock.withLock {
            return DependencyContainer.dependencies[String(describing: type)] as? T
        }
    }
}
