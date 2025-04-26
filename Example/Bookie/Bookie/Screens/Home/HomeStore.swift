//
//  HomeStore.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting
import SwiftData


extension HomeScreen {
    
    //MARK: - HomeAction
    enum HomeAction: Sendable, ActionLockable {
        case firstFetchBooks
        case refreshBooks
        case loadmoreBooks
        case searchBookBy(text: String)
        case gotoDetail(book: BookPersistent.SendableType)
        case swipeDelete(atOffsets: IndexSet)
    }

    enum DisplayMode: Int8 {
        case list
        case search
    }
    
    //MARK: - HomeStore
    actor HomeStore: ActionStore {
        
        private weak var state: HomeState?
        private weak var router: SRRouter<HomeRoute>?
        private let cancelBag = CancelBag()
        private var didObserveChanges: Bool = false
        
        private let bookService: BookService = .init()
        private let actionLocker = ActionLocker()
        private var searchLoadmoreToken: FetchNextToken<BookPersistent>?
        private var loadmoreToken: FetchNextToken<BookPersistent>?
        private var displayMode: DisplayMode = .list
        
        func binding(state: HomeState) {
            guard self.state == nil else { return }
            self.state = state
            _observeBookChanges()
        }
        
        func binding(router: SRRouter<HomeRoute>) {
            guard self.router == nil else { return }
            self.router = router
        }
        
        nonisolated func receive(action: HomeAction) {
            Task {
                guard await actionLocker.canExecute(action) else { return }
                do {
                    switch action {
                    case .swipeDelete(let offsets):
                        try await _deleteBooks(atOffsets: offsets)
                    case .refreshBooks where await displayMode == .list:
                        try await _refreshBooks()
                    case .loadmoreBooks where await displayMode == .list:
                        try await _loadmoreBooks()
                    case .loadmoreBooks where await displayMode == .search:
                        guard let text = await state?.seachText else { break }
                        await _searchBooks(byText: text)
                    case .firstFetchBooks:
                        try await _firstFetchAllBooks()
                    case .searchBookBy(let text):
                        if text.isEmpty {
                            await updateDisplayMode(.list)
                        } else {
                            await updateDisplayMode(.search)
                        }
                        await _searchBooks(byText: text)
                    case .gotoDetail(let book):
                        await router?.trigger(to: .bookDetailScreen(book: book), with: .allCases.randomElement() ?? .push)
                    default: break
                    }
                } catch let error as LocalizedError {
                    await state?.showError(error)
                }
                await actionLocker.unlock(action)
            }
        }
        
        deinit {
            cancelBag.cancelAllInTask()
        }
    }
}

//MARK: - Private Jobs
extension HomeScreen.HomeStore {
    
    private func updateDisplayMode(_ mode: HomeScreen.DisplayMode) {
        displayMode = mode
    }
    
    private func _deleteBooks(atOffsets offsets: IndexSet) async throws {
        let persistentIds = await state?.removeBooks(atOffsets: offsets) ?? []
        guard !persistentIds.isEmpty else { return }
        try await bookService.deleteBooks(byPersistentIdentifiers: persistentIds)
    }
    
    private func _searchBooks(byText text: String) {
        Task {
            try await Task.sleep(for: .milliseconds(300))
            searchLoadmoreToken = searchLoadmoreToken?.validate(for: text)
            let token = searchLoadmoreToken
            let result = try await bookService.searchBooks(query: text, nextToken: searchLoadmoreToken)
            if token != nil {
                await state?.appendAllBooks(books: result.models)
            } else {
                await state?.repaceAndBackupListBooks(books: result.models)
            }
            searchLoadmoreToken = result.nextToken
        }.store(in: cancelBag, withIdentifier:#function)
    }
    
    private func _firstFetchAllBooks() async throws {
        guard let state, await state.books.isEmpty else { return }
        try await _refreshBooks()
    }
    
    private func _fetchAllBook(isRefresh: Bool) async throws {
        if isRefresh { loadmoreToken = nil }
        let result = try await bookService.fetchAllBooks(nextToken: loadmoreToken)
        if isRefresh {
            await state?.replaceBooks(books: result.models)
        } else {
            await state?.appendAllBooks(books: result.models)
        }
        loadmoreToken = result.nextToken
    }
    
    private func _refreshBooks() async throws {
        try await _fetchAllBook(isRefresh: true)
    }
    
    private func _loadmoreBooks() async throws {
        guard loadmoreToken != nil else { return }
        await state?.updateLoadmore(isLoadingMore: true)
        try await _fetchAllBook(isRefresh: false)
        await state?.updateLoadmore(isLoadingMore: false)
    }
}

//MARK: - Observe BookPersistent Changes
extension HomeScreen.HomeStore {
    
    private func _observeBookChanges() {
        guard !didObserveChanges else { return }
        didObserveChanges = true
        Task.detached {[weak self] in
            let stream = await DatabaseActor.shared.changesStream
            try Task.checkCancellation()
            for await changes in stream {
                switch changes {
                case .insertedIdentifiers(let ids):
                    await self?._observeInserted(from: ids)
                case .deletedIdentifiers(let ids):
                    await self?._observeDeleted(from: ids)
                case .updatedIdentifiers(let ids):
                    await self?._observeUpdated(from: ids)
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
