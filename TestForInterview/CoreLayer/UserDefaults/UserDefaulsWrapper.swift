//
//  UserDefaulsWrapper.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 01.10.2025.
//

import Foundation

enum UserDefaulsKey: String {
    case theme
}

@propertyWrapper
struct UserDefaultWrapper<T> {
    let userDefaults: UserDefaults
    let key: UserDefaulsKey
    let defaultValue: T
    
    init(
        key: UserDefaulsKey,
        defaultValue: T,
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.userDefaults = userDefaults
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get { return userDefaults.object(forKey: key.rawValue) as? T ?? defaultValue }
        set { userDefaults.set(newValue, forKey: key.rawValue) }
    }
}
