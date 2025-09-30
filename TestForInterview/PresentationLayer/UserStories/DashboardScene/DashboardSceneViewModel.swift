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
    func didSelectPage(page: Int)
    func viewDidLoad()
    func viewWillAppear()
}

final class DashboardSceneViewModel: DashboardSceneVMP {
    var movies: CurrentValueSubject<[MovieItem], Never> = .init([])
    var currentSelectedPage: Int = 1
    
    var isLoadingState: AnyPublisher<Bool, Never> {
        guard let paginator = self.paginator else {
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
    private var paginator: CombinePaginator<Movie>?
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
        self.paginator?.fetchFirstPage()
    }
    
    // MARK: Public methods
    func didSelectPage(page: Int) {
        self.currentSelectedPage = page
        self.paginator?.currentPage = page - 1
        self.paginator?.loadNextPage()
    }
    
    // MARK: Private methods
    private func configure() {
        self.paginator = CombinePaginator<Movie>(
            fetch: { [weak self] page in
                guard let self = self else {
                    return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
                }
                
                return self.moviesRepository.topRated(language: Locale.current.identifier, page: Int32(page), region: self.region)
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
        )
        
        
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
    }
}
