//
//  SceneTransitionMethod.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import UIKit

enum SceneTransitionMethod: Equatable {
    case push(animated: Bool = false)
    case root(animated: Bool = false, option: UIView.AnimationOptions? = nil)
}
