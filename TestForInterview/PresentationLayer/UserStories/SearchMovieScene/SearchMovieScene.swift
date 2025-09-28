//
//  SearchMovieScene.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 26.09.2025.
//

import SwiftUI

struct SearchMovieScene<ViewModel: SearchMovieSceneVMP>: View {
    @ObservedObject var viewModel: ViewModel
    @State var collectionViewContentHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color(.bg)
            VStack(spacing: 24) {
                searchBlock
                    .padding(.horizontal, 16)
                
                ZStack {
                    if viewModel.nothingFound {
                        VStack {
                            Image(.movieList)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(.txt))
                        }
                        .frame(height: 260)
                        
                        Spacer()
                    } else if viewModel.firstPageLoading {
                        LoaderView()
                    } else {
                        collectionView
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.nothingFound)
                .animation(.easeInOut(duration: 0.3), value: viewModel.firstPageLoading)
                
                Spacer()
            }
            .padding(.top, 24)
        }
        .modifier(NavigationBarModifier(title: viewModel.title))
    }

    private var searchBlock: some View {
        VStack(spacing: 16) {
            SearchBarView(text: $viewModel.input)
            
            Text(viewModel.searchResult)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(.txt))
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.interactiveSpring, value: viewModel.searchResult)
        }
    }
    
    private func posterView(movie: SearchMovieItem) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                CAsyncImage(url: movie.item.posterURL()) { image in
                    image
                        .resizable()
                        .cornerRadius(12)
                        .frame(width: 163, height: 233)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundColor(Color.gray.opacity(0.2))
                        .frame(width: 163, height: 233)
                }
                
                Image(.star)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(movie.isFavorite ? Color(.favorite) : Color(.star))
                    .frame(width: 20, height: 19.7)
                    .padding(.top, 10)
                    .padding(.trailing, 10)
            }
            
            VStack(spacing: 0) {
                Text(movie.item.title)
                    .foregroundColor(Color(.txt))
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(movie.item.ratingLocalized())
                    .foregroundColor(Color(.txt))
                    .font(.system(size: 10, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var collectionView: some View {
        CollectionView(
            viewModel.movies,
            layout: twoColumnGrid(spacing: 8, estimatedHeight: 269),
            isScrollEnabled: true,
            prefetchThreshold: 6,
            onReachedEnd: { viewModel.loadNextPage() },
            didSelect: { viewModel.didSelectMovie($0) }
        ) { movie in
            posterView(movie: movie)
        }
    }
    
    private func twoColumnGrid(spacing: CGFloat = 8, estimatedHeight: CGFloat = 180) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(269)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = spacing * 1.5
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

#Preview {
    SearchMovieScene(viewModel: SearchMovieSceneViewModel())
}
