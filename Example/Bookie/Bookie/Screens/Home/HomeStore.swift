//
//  HomeStore.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting
import SwiftData

//MARK: - HomeAction
extension HomeScreen {
    
    enum HomeAction: Sendable {
        case firstFetchBooks
        case refreshBooks
        case loadmoreBooks
        case searchBookBy(text: String)
        case gotoDetail(book: BookModel)
        case swipeDelete(atOffsets: IndexSet)
    }
}

//MARK: - HomeStore
extension HomeScreen {
    
    enum DisplayMode {
        case list
        case search
    }
    
    final class HomeStore: ActionStore {
        
        private weak var state: HomeState?
        private weak var router: SRRouter<HomeRoute>?
        private let cancelBag = CancelBag()
        private var didObserveChanges: Bool = false
        nonisolated private lazy var bookService: BookService = .init()
        
        private var searchLoadmoreToken: FetchNextToken<BookPersistent>?
        private var loadmoreToken: FetchNextToken<BookPersistent>?
        private var displayMode: DisplayMode = .list
        
        func binding(state: HomeState, router: SRRouter<HomeRoute>) {
            self.state = state
            self.router = router
            _observeBookChanges()
        }
        
        func receive(action: HomeAction) {
            assert((state != nil && router != nil) || EnvironmentRunner.current == .livePreview,
                   "Need binding state, router and book service")

            switch action {
            case .swipeDelete(let offsets):
                _deleteBooks(atOffsets: offsets)
            case .refreshBooks where displayMode == .list:
                _refreshBooks()
            case .loadmoreBooks where displayMode == .list:
                _loadmoreBooks()
            case .loadmoreBooks where displayMode == .search:
                guard let text = state?.seachText else { break }
                _searchBooks(byText: text)
            case .firstFetchBooks:
                _firstFetchAllBooks()
            case .searchBookBy(let text):
                if text.isEmpty {
                    displayMode = .list
                } else {
                    displayMode = .search
                }
                _searchBooks(byText: text)
            case .gotoDetail(let book):
                router?.trigger(to: .bookDetailScreen(book: book), with: .allCases.randomElement() ?? .push)
            default: break
            }
        }
        
        deinit {
            cancelBag.cancelAllInTask()
        }
    }
}

//MARK: - Private Jobs
extension HomeScreen.HomeStore {
    
    private func _deleteBooks(atOffsets offsets: IndexSet) {
        Task {
            let persistentIds = state?.removeBooks(atOffsets: offsets) ?? []
            guard !persistentIds.isEmpty else { return }
            try await bookService.deleteBooks(byPersistentIdentifiers: persistentIds)
        }
    }
    
    private func _searchBooks(byText text: String) {
        Task {
            searchLoadmoreToken = searchLoadmoreToken?.validate(for: text)
            let token = searchLoadmoreToken
            let result = try await bookService.searchBooks(query: text, nextToken: searchLoadmoreToken)
            if token != nil {
                state?.appendAllBooks(books: result.models)
            } else {
                state?.repaceAndBackupListBooks(books: result.models)
            }
            searchLoadmoreToken = result.nextToken
        }.store(in: cancelBag, withIdentifier:#function)
    }
    
    private func _firstFetchAllBooks() {
        guard let state, state.books.isEmpty else { return }
        _refreshBooks()
    }
    
    private func _fetchAllBook(isRefresh: Bool) {
        Task {
            do {
                state?.updateLoadmore(isLoadingMore: !isRefresh)
                if isRefresh { loadmoreToken = nil }
                let result = try await bookService.fetchAllBooks(nextToken: loadmoreToken)
                if isRefresh {
                    state?.replaceBooks(books: result.models)
                } else {
                    state?.appendAllBooks(books: result.models)
                }
                loadmoreToken = result.nextToken
                state?.updateLoadmore(isLoadingMore: false)
            } catch {
                state?.updateLoadmore(isLoadingMore: false)
            }
        }
    }
    
    private func _refreshBooks() {
        _fetchAllBook(isRefresh: true)
    }
    
    private func _loadmoreBooks() {
        guard loadmoreToken != nil else { return }
        _fetchAllBook(isRefresh: false)
    }
}

//MARK: - Observe BookPersistent Changes
extension HomeScreen.HomeStore {
    
    private func _observeBookChanges() {
        guard !didObserveChanges else { return }
        didObserveChanges = true
        Task.detached {[weak self] in
            guard let self else { return }
            let stream = await DatabaseActor.shared.changesStream
            try Task.checkCancellation()
            for await changes in stream {
                switch changes {
                case .insertedIdentifiers(let ids):
                    await self._observeInserted(from: ids)
                case .deletedIdentifiers(let ids):
                    await self._observeDeleted(from: ids)
                case .updatedIdentifiers(let ids):
                    await self._observeUpdated(from: ids)
                }
            }
        }.store(in: cancelBag, withIdentifier: "HommeStore.observeBookChanges")
    }
    
    nonisolated private func _observeInserted(from ids: [PersistentIdentifier]) async  {
        guard !ids.isEmpty else { return }
        let books = await bookService.books(fromPersistentIdentifiers: ids)
        guard !books.isEmpty else { return }
        await state?.insertNewBoosk(books)
    }
    
    nonisolated private func _observeUpdated(from ids: [PersistentIdentifier]) async  {
        guard !ids.isEmpty else { return }
        let books = await bookService.books(fromPersistentIdentifiers: ids)
        guard !books.isEmpty else { return }
        await state?.updateBooks(books)
    }
    
    nonisolated private func _observeDeleted(from ids: [PersistentIdentifier]) async  {
        guard !ids.isEmpty else { return }
        await state?.removeBooks(byPersistentIdentifiers: ids)
    }
}
