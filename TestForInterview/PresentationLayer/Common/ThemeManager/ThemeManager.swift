//
//  ThemeManager.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 01.10.2025.
//

import Combine
import UIKit

final class ThemeManager {
    static let shared = ThemeManager()

    // MARK: User defaults
    @UserDefaultWrapper(key: .theme, defaultValue: UIUserInterfaceStyle.unspecified.rawValue) private var userInterfaceStyleRawValue: Int

    // MARK: Init
    init() {}
    
    // MARK: Public
    var currentTheme: UIUserInterfaceStyle {
        return storedInterfaceStyle
    }
    
    private(set) lazy var interfaceStylePublisher: CurrentValueSubject<UIUserInterfaceStyle, Never> = {
        CurrentValueSubject<UIUserInterfaceStyle, Never>(storedInterfaceStyle)
    }()

    func updateInterfaceStyle(_ userInterfaceStyle: UIUserInterfaceStyle) {
        self.storedInterfaceStyle = userInterfaceStyle
    }
    
    // MARK: Private 
    private var storedInterfaceStyle: UIUserInterfaceStyle {
        get {
            UIUserInterfaceStyle(rawValue: userInterfaceStyleRawValue) ?? .unspecified
        }
        set {
            userInterfaceStyleRawValue = newValue.rawValue
            interfaceStylePublisher.value = newValue
        }
    }

}
