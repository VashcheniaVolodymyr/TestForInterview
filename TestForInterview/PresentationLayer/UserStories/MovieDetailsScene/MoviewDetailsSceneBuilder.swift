//
//  MoviewDetailsSceneBuilder.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import SwiftUI

extension Scenes {
    static func movieDetails(movieId: Int32) -> any SceneBuilderProtocol {
        struct Scene: SceneBuilderProtocol {
            let movieId: Int32
            var transition: SceneTransitionMethod = .push(animated: true)
            
            func buildScene() -> UIViewController {
                let viewModel = MovieDetailsSceneViewModel(movieId: movieId)
                let view = MovieDetailsScene(viewModel: viewModel)
                return UIHostingController(rootView: view)
            }
        }
        
        return Scene(movieId: movieId)
    }
}
