//
//  MovieDetailsScene.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import SwiftUI
import SDWebImage

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
            SDWebImageView(
                url: viewModel.posterURL,
                placeholder: nil,
                contentMode: .center,
                cornerRadius: 14,
                context: imageContext,
                showsActivity: true,
                transition: .fade
            )
            .frame(width: 250, height: 377)
            
            Text(viewModel.voteAverage)
                .foregroundColor(Color(.txt))
                .font(.system(size: 10, weight: .medium))
        }
    }
    
    private var imageContext: [SDWebImageContextOption : Any] {
        let imageResizingTransformer = SDImageResizingTransformer(
            size: CGSize(width: 250, height: 377),
            scaleMode: .aspectFill
        )
        let round  = SDImageRoundCornerTransformer(radius: 12,
                                                   corners: .allCorners,
                                                   borderWidth: 0,
                                                   borderColor: nil)

        let tint = SDImageTintTransformer(color: .clear)

        let pipeline = SDImagePipelineTransformer(transformers: [imageResizingTransformer, round, tint])
        
        return [.imageTransformer : pipeline]
    }
}

#Preview {
    MovieDetailsScene(viewModel: MovieDetailsSceneViewModel(movieId: 278))
}
