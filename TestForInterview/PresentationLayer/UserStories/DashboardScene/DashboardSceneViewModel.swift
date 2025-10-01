//
//  DashboardSceneViewModel.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 27.09.2025.
//
import Combine
import Foundation

protocol DashboardSceneVMP: AnyObject {
    var movies: CurrentValueSubject<[MovieItem], Never> { get }
    var totalPages: Int { get }
    var isLoadingState: AnyPublisher<Bool, Never> { get }
    var currentSelectedPage: Int { get }
    var averageRating: AnyPublisher<Double, Never> { get }
    func didSelectPage(page: Int)
    func refresh()
    func viewDidLoad()
    func viewWillAppear()
}

final class DashboardSceneViewModel: DashboardSceneVMP {
    var movies: CurrentValueSubject<[MovieItem], Never> = .init([])
    var currentSelectedPage: Int = 1
    
    var averageRating: AnyPublisher<Double, Never> {
        return movies.map { movies -> Double in
            let ratings = movies.map { $0.item.voteAverage }
            guard ratings.isEmpty.NOT else { return 0 }
            let sum = ratings.reduce(0, +)
            return sum / Double(ratings.count)
        }
        .eraseToAnyPublisher()
    }
    
    var isLoadingState: AnyPublisher<Bool, Never> {
        guard let paginator = self.paginator else {
            return Just(false).eraseToAnyPublisher()
        }
        
        return Publishers.CombineLatest3(
            paginator.$selectedPage,
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
    
    var totalPages: Int {
        guard let paginator = self.paginator else {
            return 0
        }
        
        return paginator.totalPages
    }
        
    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []
    private let moviesRepository: MoviesRepository
    private let favoriteRepository: FavoriteRepository
    private var paginator: DualStreamPaginator<Movie>?
    private var update: PassthroughSubject<Void, Never> = .init()
    
    private lazy var region: String = {
        if #available(iOS 16, *) {
            return Locale.current.region?.identifier ?? "UA"
        } else {
            return Locale.current.regionCode ?? "UA"
        }
    }()
    
    // MARK: Init
    init(
        moviesRepository: MoviesRepository = MoviesRepositoryImpl(),
        favoriteRepository: FavoriteRepository = FavoriteRepositoryImpl()
    ) {
        self.moviesRepository = moviesRepository
        self.favoriteRepository = favoriteRepository
        
        configure()
    }
    
    // MARK: Lifecycle
    func viewWillAppear() {
        update.send(Void())
    }
    
    func viewDidLoad() {
        self.paginator?.fetchFirst()
    }
    
    // MARK: Public methods
    func refresh() {
        self.paginator?.reset()
        self.paginator?.fetchFirst(start: .firstPage)
    }
    
    func didSelectPage(page: Int) {
        self.currentSelectedPage = page
        self.paginator?.load(page: page)
    }
    
    // MARK: Private methods
    private func configure() {
        self.paginator = DualStreamPaginator(fetch: { [weak self] page in
            guard let self = self else {
                return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
            }
            
            return self.moviesRepository.topRated(language: Locale.current.identifier, page: Int32(page), region: self.region)
                .map({ list in
                    return DualPage<Movie>(
                        page: list.page,
                        totalPages: list.totalPages,
                        totalResults: list.totalResults,
                        items: list.movies
                    )
                })
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }, direction: .ascending)
        
        
        paginator?.$items
            .combineLatest(update)
            .receive(on: DispatchQueue.main)
            .map { movies, _ in
                return movies.uniqueBy(\.id).map {
                    let isFaforite = self.favoriteRepository.isFavorite($0)
                    
                    return MovieItem(isFavorite: isFaforite, item: $0)
                }
            }
            .assign(to: \.value, on: movies, ownership: .weak)
            .store(in: &cancellables)
        
        paginator?.$selectedPage
            .removeDuplicates()
            .sink(receiveValue: { [weak self] page in
                self?.currentSelectedPage = page
            })
            .store(in: &cancellables)
    }
}
