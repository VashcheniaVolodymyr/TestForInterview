//
//  BaseNavigationController.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import UIKit

class BaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    // MARK: Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
}
