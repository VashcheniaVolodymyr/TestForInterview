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
        ZStack {
            Color(.bg)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    posterView
                    
                    Text(viewModel.overview)
                        .foregroundColor(Color(.txt))
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 12))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(viewModel.releaseDate)
                        .foregroundColor(Color(.txt))
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    AppButton(config: viewModel.configurableAppButton.config, style: viewModel.configurableAppButton.style)
                        .id(viewModel.configurableAppButton.id)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
        .modifier(NavigationBarModifier(title: viewModel.title))
    }
    
    
    private var posterView: some View {
        VStack(spacing: 8) {
            CAsyncImage(url: viewModel.posterURL) { image in
                image
                    .resizable()
                    .cornerRadius(12)
                    .frame(width: 250, height: 377)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(Color.gray.opacity(0.2))
                    .frame(width: 250, height: 377)
            }
            .id(viewModel.posterURL?.absoluteString)
            
            Text(viewModel.voteAverage)
                .foregroundColor(Color(.txt))
                .font(.system(size: 10, weight: .medium))
        }
    }
}

#Preview {
    MovieDetailsScene(viewModel: MovieDetailsSceneViewModel(movieId: 278))
}
