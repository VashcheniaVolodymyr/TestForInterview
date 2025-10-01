//
//  DualStreemPaginator.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 30.09.2025.
//

import Foundation
import Combine

public enum DualRequestStatus: Int { case none, inProgress, done, error }
public enum PagingDirection { case ascending, descending }
public enum StartStrategy { case firstPage, lastPage, custom(Int) }

public struct DualPage<Element> {
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

private struct FetchResult<Element> {
    let page: DualPage<Element>
    let success: Bool
}

private enum Event<Element> {
    case result(FetchResult<Element>)
    case select(Int)
}

public final class DualStreamPaginator<Element>: ObservableObject {
    // MARK: - Published
    @Published public private(set) var items: [Element] = []
    @Published public private(set) var status: DualRequestStatus = .none
    @Published public private(set) var errorText: String?
    @Published public private(set) var selectedPage: Int = 0
    @Published public private(set) var totalPages: Int = 0
    @Published public private(set) var totalResults: Int = 0
    @Published public private(set) var direction: PagingDirection
    
    // MARK: - API
    public init(fetch: @escaping (_ page: Int) -> AnyPublisher<DualPage<Element>, Error>,
                direction: PagingDirection = .ascending) {
        self.fetch = fetch
        self.direction = direction
        bind()
    }
    
    public func fetchFirst(start: StartStrategy = .firstPage) {
        reset()
        switch start {
        case .firstPage:
            select(page: 1, prefetchNeighbor: true)
        case .custom(let p):
            select(page: p, prefetchNeighbor: true)
        case .lastPage:
            discoverTotalPagesThenSelectLast()
        }
    }
    
    public func load(page: Int) { select(page: page, prefetchNeighbor: true) }
    
    public func reset() {
        cancellables.removeAll()
        pageRequests = PassthroughSubject<Int, Never>()
        selectionEvents = PassthroughSubject<Int, Never>()
        inFlight.removeAll()
        loadedPages.removeAll()
        pageCache.removeAll()
        items = []
        status = .none
        errorText = nil
        selectedPage = 0
        totalPages = 0
        totalResults = 0
        edgeResetTarget = nil
        bind()
    }
    
    // MARK: - Private
    private let fetch: (_ page: Int) -> AnyPublisher<DualPage<Element>, Error>
    private var cancellables = Set<AnyCancellable>()
    
    private var pageRequests = PassthroughSubject<Int, Never>()
    private var selectionEvents = PassthroughSubject<Int, Never>()
    
    private var inFlight = Set<Int>()
    private var loadedPages = Set<Int>()
    private var pageCache: [Int: [Element]] = [:]
    private var step: Int { direction == .ascending ? 1 : -1 }
    private var edgeResetTarget: Int?
    
    private struct State<E> {
        var selected: Int = 0
        var items: [E] = []
        var totalPages: Int = 0
        var totalResults: Int = 0
        var edge: Int = 0
        mutating func clear() {
            items = []
            totalPages = 0
            totalResults = 0
            edge = 0
        }
    }
    
    private func bind() {
        let results = pageRequests
            .removeDuplicates()
            .filter { [weak self] page in
                guard let self = self else { return false }
                if page < 1 { return false }
                if self.totalPages > 0 && page > self.totalPages { return false }
                let allowForce = (self.edgeResetTarget == page)
                return !self.inFlight.contains(page) && (allowForce || !self.loadedPages.contains(page))
            }
            .handleEvents(receiveOutput: { [weak self] page in
                self?.status = .inProgress
                self?.errorText = nil
                self?.inFlight.insert(page)
            })
            .flatMap(maxPublishers: .max(2)) { [weak self] page -> AnyPublisher<FetchResult<Element>, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.fetch(page)
                    .map { FetchResult(page: $0, success: true) }
                    .handleEvents(receiveCompletion: { [weak self] completion in
                        if case .failure = completion {
                            self?.loadedPages.insert(page)
                            self?.inFlight.remove(page)
                        }
                    })
                    .catch { [weak self] err -> AnyPublisher<FetchResult<Element>, Never> in
                        self?.errorText = err.localizedDescription
                        self?.status = .error
                        let empty = DualPage<Element>(
                            page: page,
                            totalPages: self?.totalPages ?? 0,
                            totalResults: self?.totalResults ?? 0,
                            items: []
                        )
                        return Just(FetchResult(page: empty, success: false)).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] result in
                guard let self = self else { return }
                self.inFlight.remove(result.page.page)
                self.loadedPages.insert(result.page.page)
                self.pageCache[result.page.page] = result.page.items
                
                if self.totalPages == 0 && result.page.totalPages > 0 { self.totalPages = result.page.totalPages }
                if self.totalResults == 0 && result.page.totalResults > 0 { self.totalResults = result.page.totalResults }
                
                if result.success, let target = self.edgeResetTarget, target == result.page.page {
                    self.pageCache.removeAll()
                    self.loadedPages.removeAll()
                    self.edgeResetTarget = nil
                    
                    self.pageCache[result.page.page] = result.page.items
                    self.loadedPages.insert(result.page.page)
                }
            })
            .map { Event.result($0) }
            .eraseToAnyPublisher()
        
        let selections = selectionEvents
            .removeDuplicates()
            .map { Event<Element>.select($0) }
            .eraseToAnyPublisher()
        
        Publishers.Merge(results, selections)
            .scan(State<Element>()) { [weak self] state, event in
                var state = state
                let dir = self?.direction ?? .ascending
                
                switch event {
                case .select(let p):
                    state.selected = p
                    state.items = self?.collectPages(upTo: p) ?? []
                    if dir == .ascending {
                        state.edge = max(state.edge, p)
                    } else {
                        state.edge = (state.edge == 0) ? p : min(state.edge, p)
                    }
                    
                case .result(let res):
                    if state.totalPages == 0 { state.totalPages = res.page.totalPages }
                    if state.totalResults == 0 { state.totalResults = res.page.totalResults }
                    
                    if dir == .ascending {
                        state.edge = max(state.edge, res.page.page)
                    } else {
                        state.edge = (state.edge == 0) ? res.page.page : min(state.edge, res.page.page)
                    }
                    
                    let sel = state.selected
                    if sel > 0 {
                        if (dir == .ascending && res.page.page <= sel) ||
                            (dir == .descending && (
                                (self?.totalPages ?? 0) == 0
                                ? (res.page.page >= sel)
                                : (res.page.page <= (self?.totalPages ?? 0) && res.page.page >= sel)
                            )) {
                            state.items = self?.collectPages(upTo: sel) ?? []
                        }
                    }
                }
                
                return state
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.selectedPage = state.selected
                self.items = state.items
                if self.totalPages == 0 && state.totalPages > 0 { self.totalPages = state.totalPages }
                if self.totalResults == 0 && state.totalResults > 0 { self.totalResults = state.totalResults }
                
                let exhausted: Bool
                if self.totalPages == 0 {
                    exhausted = false
                } else {
                    exhausted = (self.direction == .ascending)
                    ? (state.edge >= self.totalPages)
                    : (state.edge <= 1 && state.edge != 0)
                }
                if exhausted && self.inFlight.isEmpty {
                    self.status = .done
                } else if self.status != .error {
                    self.status = .inProgress
                }
            }
            .store(in: &cancellables)
    }
    
    private func collectPages(upTo selected: Int) -> [Element] {
        guard selected >= 1 else { return [] }
        var merged: [Element] = []
        
        if direction == .ascending {
            if selected >= 1 {
                for p in 1...selected {
                    if let arr = pageCache[p] { merged.append(contentsOf: arr) }
                }
            }
        } else {
            if totalPages > 0 {
                for p in stride(from: totalPages, through: selected, by: -1) {
                    if let arr = pageCache[p] { merged.append(contentsOf: arr) }
                }
            } else {
                let keys = pageCache.keys.filter { $0 >= selected }.sorted(by: >)
                for k in keys { if let arr = pageCache[k] { merged.append(contentsOf: arr) } }
            }
        }
        return merged
    }
    
    // MARK: - High-level ops
    private func select(page p: Int, prefetchNeighbor: Bool) {
        guard p >= 1 else { return }
        
        if p == 1 || (totalPages > 0 && p == totalPages) {
            edgeResetTarget = p
        }
        
        selectionEvents.send(p)
        
        if pageCache[p] == nil && !inFlight.contains(p) && !loadedPages.contains(p) {
            pageRequests.send(p)
        }
        
        if prefetchNeighbor {
            let neighbor = p + step
            if neighbor >= 1, (totalPages == 0 || neighbor <= totalPages) {
                if pageCache[neighbor] == nil && !inFlight.contains(neighbor) && !loadedPages.contains(neighbor) {
                    pageRequests.send(neighbor)
                }
            }
        }
    }
    
    private func discoverTotalPagesThenSelectLast() {
        fetch(1)
            .sink(receiveCompletion: { [weak self] comp in
                if case .failure(let err) = comp {
                    self?.errorText = err.localizedDescription
                    self?.status = .error
                }
            }, receiveValue: { [weak self] first in
                guard let self = self else { return }
                self.totalPages = first.totalPages
                self.totalResults = first.totalResults
                let last = first.totalPages
                self.select(page: last, prefetchNeighbor: true)
            })
            .store(in: &cancellables)
    }
}

