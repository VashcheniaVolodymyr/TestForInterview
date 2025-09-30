//
//  SearchMovieSceneViewModel.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 26.09.2025.
//

import Foundation
import Combine

struct MovieItem: Hashable, Identifiable {
    let id: Int
    let isFavorite: Bool
    let item: Movie
    
    init(isFavorite: Bool, item: Movie) {
        self.isFavorite = isFavorite
        self.item = item
        self.id = item.id
    }
}

protocol SearchMovieSceneVMP: ObservableObject {
    var title: String { get }
    var input: String { get set }
    var searchResult: String { get }
    var movies: [MovieItem] { get }
    var nothingFound: Bool { get }
    var firstPageLoading: Bool { get }
    
    func onAppear()
    func didSelectMovie(_ movie: MovieItem)
    func loadNextPage()
}

final class SearchMovieSceneViewModel: SearchMovieSceneVMP {
    // MARK: Public
    private(set) var title: String = NSLocalizedString("search", comment: "")
   
    @Published var input: String = ""
    @Published var searchResult: String = String(format: NSLocalizedString("search_results", comment: ""), "0")
    @Published var movies: [MovieItem] = []
    @Published var nothingFound: Bool = false
    @Published var firstPageLoading: Bool = false
    
    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []
    private let movieRepository: MoviesRepository
    private let favoriteRepository: FavoriteRepository
    private var paginator: CombinePaginator<Movie>?
    
    private var debouncedInput: AnyPublisher<String, Never> {
        $input
            .debounce(for: 1.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private var notFoudState: AnyPublisher<Bool, Never> {
        guard let paginator else {
            return Just(false).eraseToAnyPublisher()
        }
        
        return Publishers.CombineLatest4(
            paginator.$currentPage,
            paginator.$items,
            paginator.$status,
            debouncedInput
        )
        .map { page, items, status, input in
            let inputHasMoreThanTwoSymbols: Bool = input.count > 2
            
            switch (page, items.count, status, inputHasMoreThanTwoSymbols) {
            case (0, 0, .done, true):
                return true
            case (1, 0, .done, true):
                return true
            default:
                return false
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    private var fistPageLoading: AnyPublisher<Bool, Never> {
        guard let paginator else {
            return Just(false).eraseToAnyPublisher()
        }
        
        return Publishers.CombineLatest3(
            paginator.$currentPage,
            paginator.$items,
            paginator.$status
        )
        .map { page, items, status in
            
            switch (page, items.count, status) {
            case (0, 0, .inProgress):
                return true
            case (1, 0, .inProgress):
                return true
            default:
                return false
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    // MARK: Injection
    @Injected private var navigation: Navigation
    
    // MARK: Init
    init(
        movieRepository: MoviesRepository = MoviesRepositoryImpl(),
        favoriteRepository: FavoriteRepository = FavoriteRepositoryImpl()
    ) {
        self.favoriteRepository = favoriteRepository
        self.movieRepository = movieRepository
        
        configure()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: Protocol
    func onAppear() {
        updateFavorites()
    }
    
    func loadNextPage() {
        self.paginator?.loadNextPage()
    }
    
    func didSelectMovie(_ movie: MovieItem) {
        self.navigation.navigate(builder: Scenes.movieDetails(movieId: Int32(movie.item.id)))
    }
    
    // MARK: Private methods
    private func configure() {
        self.paginator = CombinePaginator<Movie> { [weak self] page in
            guard let movieRepository = self?.movieRepository else {
                return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
            }
            
            guard let input = self?.input else {
                return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
            }
            
            return movieRepository.search(query: input, page: Int32(page), language: Locale.current.identifier)
                .map({ list in
                    return Page<Movie>(
                        page: list.page,
                        totalPages: list.totalPages,
                        totalResults: list.totalResults,
                        items: list.movies
                    )
                })
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        
        debouncedInput
            .filter { $0.count > 2 }
            .sink { [weak self] _ in
                self?.paginator?.fetchFirstPage()
            }
            .store(in: &cancellables)
        
        debouncedInput
            .filter { $0.count < 3 }
            .sink { [weak self] _ in
                self?.paginator?.reset()
            }
            .store(in: &cancellables)
        
        paginator?.$items
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.movies = movies.uniqueBy(\.id).map {
                    let isFaforite = self.favoriteRepository.isFavorite($0)
                    
                    return MovieItem(isFavorite: isFaforite, item: $0)
                }
            })
            .store(in: &cancellables)
        
        paginator?.$totalResults
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] totalResuls in
                guard let self = self else { return }
                self.searchResult = String(format: NSLocalizedString("search_results", comment: ""), totalResuls.description)
            })
            .store(in: &cancellables)
        
        notFoudState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                guard let self = self else { return }
                self.nothingFound = state
            })
            .store(in: &cancellables)
        
        fistPageLoading
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                guard let self = self else { return }
                self.firstPageLoading = state
            })
            .store(in: &cancellables)
    }
    
    private func updateFavorites() {
        if movies.count > 0 {
            self.movies = paginator?.items.uniqueBy(\.id).map {
                let isFaforite = self.favoriteRepository.isFavorite($0)
                
                return MovieItem(isFavorite: isFaforite, item: $0)
            } ?? []
        }
    }
}
