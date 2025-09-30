//
//  SearchMovieSceneBuilder.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 26.09.2025.
//
import SwiftUI

extension Scenes {
    static func searchMovieScene() -> any SceneBuilderProtocol {
        struct Scene: SceneBuilderProtocol {
            var transition: SceneTransitionMethod = .push(animated: true)
            
            func buildScene() -> UIViewController {
                let viewModel = SearchMovieSceneViewModel()
                let view = SearchMovieScene(viewModel: viewModel)
                return UIHostingController(rootView: view)
            }
        }
        
        return Scene()
    }
}
