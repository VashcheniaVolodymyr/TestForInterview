//
//  Paginator.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 26.09.2025.
//

import Combine
import Foundation

public enum RequestStatus: Int { case none, inProgress, done }

public struct Page<Element> {
    public let page: Int
    public let totalPages: Int
    public let totalResults: Int
    public let items: [Element]
    
    public init(page: Int, totalPages: Int, totalResults: Int, items: [Element]) {
        self.page = page
        self.totalPages = totalPages
        self.totalResults = totalResults
        self.items = items
    }
}

public final class CombinePaginator<Element>: ObservableObject {
    @Published public private(set) var items: [Element] = []
    @Published public private(set) var status: RequestStatus = .none
    @Published public private(set) var errorText: String?
    @Published public private(set) var currentPage: Int = 0
    @Published public private(set) var totalPages: Int = 0
    @Published public private(set) var totalResults: Int = 0
    
    public func fetchFirstPage() { reset(); loadNextPage() }
    public func loadNextPage() { loadNext.send(()) }
    public func reset() {
        cancellables.removeAll()
        items = []
        status = .none
        errorText = nil
        currentPage = 0
        totalPages = 0
        totalResults = 0
        bind()
    }
    
    // MARK: - Init
    /// - Parameter fetch: closure that fetches a specific page and returns a publisher
    public init(fetch: @escaping (_ page: Int) -> AnyPublisher<Page<Element>, Error>) {
        self.fetch = fetch
        bind()
    }
    
    // MARK: - Private
    private let fetch: (_ page: Int) -> AnyPublisher<Page<Element>, Error>
    private let loadNext = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var hasMorePages: Bool {
        guard totalPages > 0 else { return true }
        return currentPage < totalPages
    }
    
    private func bind() {
        loadNext
            .filter { [weak self] in
                guard let self = self else { return false }
                return self.status != .inProgress && self.hasMorePages
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.status = .inProgress
                self?.errorText = nil
            })
            .flatMap(maxPublishers: .max(1)) { [weak self] _ -> AnyPublisher<Page<Element>, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let next = (self.currentPage == 0) ? 1 : (self.currentPage + 1)
                return self.fetch(next)
                    .catch { [weak self] err -> Empty<Page<Element>, Never> in
                        self?.errorText = err.localizedDescription
                        self?.status = .done
                        return .init()
                    }
                    .eraseToAnyPublisher()
            }
            .scan((items: [Element](), lastPage: 0, totalPages: 0, totalResults: 0)) { acc, page in
                var merged = acc.items
                merged.append(contentsOf: page.items)
                return (merged, page.page, page.totalPages, page.totalResults)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] acc in
                guard let self = self else { return }
                self.items = acc.items
                self.currentPage = acc.lastPage
                self.totalPages = acc.totalPages
                self.totalResults = acc.totalResults
                self.status = (self.currentPage >= self.totalPages && self.totalPages > 0) ? .done : .done
            }
            .store(in: &cancellables)
    }
}
