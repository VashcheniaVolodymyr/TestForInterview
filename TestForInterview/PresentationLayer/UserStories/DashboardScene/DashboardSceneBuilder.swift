//
//  DashboardSceneBuilder.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 27.09.2025.
//
import SwiftUI

extension Scenes {
    static func dashboard() -> any SceneBuilderProtocol {
        struct Scene: SceneBuilderProtocol {
            var transition: SceneTransitionMethod = .root(animated: true, option: .transitionCrossDissolve)
            
            func buildScene() -> UIViewController {
                let storyboard = UIStoryboard(name: "DashboardScene", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "DashboardScene") as? DashboardScene else {
                    return UIViewController()
                }
                return vc
            }
        }
        
        return Scene()
    }
}
