//
//  MovieDetailsScene.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import SwiftUI

struct MovieDetailsScene<ViewModel: MovieDetailsSceneVMP>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    MovieDetailsScene(viewModel: MovieDetailsSceneViewModel(movieId: 278))
}
