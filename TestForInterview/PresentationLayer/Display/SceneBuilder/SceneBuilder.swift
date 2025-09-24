//
//  SceneBuilder.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import UIKit

struct Scenes {}

protocol SceneBuilderProtocol {
    associatedtype Scene: UIViewController
    func buildScene() -> Scene
    var transition: SceneTransitionMethod { get set }
    var transitionStyle: UIModalTransitionStyle? { get set }
}

extension SceneBuilderProtocol {
    var transition: SceneTransitionMethod {
        get {
            return .root()
        }
        set {
            transition = newValue
        }
    }
    
    var transitionStyle: UIModalTransitionStyle? {
        get {
            return nil
        }
        set {
            transitionStyle = newValue
        }
    }
}
