//
//  MovieDetailsScene.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import SwiftUI

struct MovieDetailsScene<ViewModel: MovieDetailsSceneVMP>: View {
    @ObservedObject var viewModel: ViewModel
    @State var loader: Bool = true
    
    var body: some View {
        ZStack {
            Color(.bg)
            VStack {
                switch viewModel.state {
                case .loaded:
                    VStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            posterContent
                        }
                    }
                case .loading:
                    LoaderView()
                case .error(let errorMessage):
                    Text(errorMessage)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.txt))
                case .initial:
                    EmptyView()
                }
            }
            .animation(.easeIn(duration: 0.3), value: viewModel.state)
        }
        .modifier(NavigationBarModifier(title: viewModel.title))
        .onAppear(perform: viewModel.onAppear)
    }
    
    
    private var posterContent: some View {
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
            
            AppButton(config: viewModel.appButtonConfig)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
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
            .equatable()
            
            Text(viewModel.voteAverage)
                .foregroundColor(Color(.txt))
                .font(.system(size: 10, weight: .medium))
        }
    }
}

#Preview {
    MovieDetailsScene(viewModel: MovieDetailsSceneViewModel(movieId: 278))
}
