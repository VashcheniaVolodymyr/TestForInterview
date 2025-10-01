//
//  LaunchSceneBuilder.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 01.10.2025.
//

import SwiftUI

extension Scenes {
    static func launchScene(duration: Double, finished: VoidCallBack?) -> any SceneBuilderProtocol {
        struct Scene: SceneBuilderProtocol {
            var transition: SceneTransitionMethod = .root(animated: false, option: nil)
            let duration: Double
            let finished: VoidCallBack?
            func buildScene() -> UIViewController {
                return LaunchScene(duration: duration, finished: finished)
            }
        }
        
        return Scene(duration: duration, finished: finished)
    }
}
