//
//  HomeStore.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting
import SwiftData

//MARK: - HomeState
extension HomeScreen {
    
    @Observable @MainActor
    final class HomeState {
        
        var seachText: String = ""
        
        @ObservationIgnored
        private(set) var dataCanLoadMore: Bool = false
        
        private(set) var books: [BookModel] = []
        
        private(set) var backupBooks: [BookModel] = []
        
        func appendAllBooks(books: [BookModel]) {
            self.books.append(contentsOf: books)
        }
        
        func repaceAndBackupListBooks(books: [BookModel]) {
            if backupBooks.isEmpty {
                backupBooks = self.books
                self.books = books
            } else {
                withAnimation {
                    self.books = books
                }
            }
        }
        
        func restoreListBooks() {
            self.books = backupBooks
            backupBooks = []
        }
        
        func replaceBooks(books: [BookModel]) {
            self.books = books
        }
        
        func insertBook(_ book: BookModel) async {
            if seachText.isEmpty {
                withAnimation {
                    self.books.insert(book, at: 0)
                }
            } else {
                self.backupBooks.insert(book, at: 0)
            }
        }
        
        func updateDataCanLoadMore(_ canLoadMore: Bool) {
            self.dataCanLoadMore = canLoadMore
        }
        
        func replaceBackupBooks(books: [BookModel]) {
            backupBooks = books
        }
        
        func removeBooks(atOffsets offsets: IndexSet) -> [PersistentIdentifier] {
            guard !offsets.isEmpty && !books.isEmpty else { return [] }
            let indices = books.indices
            let willDeleteBooks = offsets.compactMap({
                indices.contains($0) ? books[$0] : nil
            })
            let persistentIds = willDeleteBooks.compactMap(\.persistentIdentifier)
            books.remove(atOffsets: offsets)
            return persistentIds
        }
        
        func removeBooks(byPersistentIdentifiers ids: [PersistentIdentifier]) {
            withAnimation {
                books.removeAll(where: {
                    guard let id = $0.persistentIdentifier else { return false }
                    return ids.contains(id)
                })
            }
        }
    }
    
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
    
    final class HomeStore: ActionStore {
        
        private weak var state: HomeState?
        private weak var router: SRRouter<HomeRoute>?
        private let cancelBag = CancelBag()
        private var didObserveChanges: Bool = false
        private lazy var fetchPagingService: FetchPagingService<BookPersistent> = .init(sortBy: [.init(\.bookId, order: .forward)])
        nonisolated private lazy var bookService: BookService = .init()
        
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
            case .refreshBooks:
                _refreshBooks()
            case .loadmoreBooks:
                _loadmoreBooks()
            case .firstFetchBooks:
                _firstFetchAllBooks()
            case .searchBookBy(let text):
                _searchBooks(byText: text)
            case .gotoDetail(let book):
                router?.trigger(to: .bookDetailScreen(book: book), with: .allCases.randomElement() ?? .push)
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
        let persistentIds = state?.removeBooks(atOffsets: offsets) ?? []
        guard !persistentIds.isEmpty else { return }
        Task {
            try await bookService.deleteBooks(byPersistentIdentifiers: persistentIds)
        }
    }
    
    private func _searchBooks(byText text: String) {
        
        guard !text.isEmpty else {
            state?.restoreListBooks()
            return
        }
        
        Task {
            let books = try  await bookService.searchBooks(query: text)
            state?.repaceAndBackupListBooks(books: books)
        }
    }
    
    private func _firstFetchAllBooks() {
        guard let state, state.books.isEmpty else { return }
        _refreshBooks()
    }
    
    private func _fetchPagingBooks() {
        let offset = fetchPagingService.offset
        Task {
            let books = try await bookService.fetchAllBooks(offset: offset,
                                                            limit: fetchPagingService.limit,
                                                            sortBy: fetchPagingService.sortBy)
            if offset == .zero {
                state?.replaceBooks(books: books)
            } else {
                state?.appendAllBooks(books: books)
            }
            state?.updateDataCanLoadMore(books.count >= fetchPagingService.limit)
        }
    }
    
    private func _refreshBooks() {
        fetchPagingService.reset()
        _fetchPagingBooks()
    }
    
    private func _loadmoreBooks() {
        fetchPagingService.nextPage()
        _fetchPagingBooks()
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
        for book in books {
            await state?.insertBook(book)
        }
    }
    
    nonisolated private func _observeUpdated(from ids: [PersistentIdentifier]) async  {
        guard !ids.isEmpty else { return }
        let books = await bookService.books(fromPersistentIdentifiers: ids)
        guard !books.isEmpty else { return }
        
        var allBooks = (await state?.books) ?? []
        var backupBooks = (await state?.backupBooks) ?? []
        
        guard !allBooks.isEmpty else { return }
        for book in books {
            if let index = await state?.books.firstIndex(where: { $0.bookId == book.bookId}) {
                allBooks[index] = book
            }
            guard !backupBooks.isEmpty else { continue }
            if let index = await state?.backupBooks.firstIndex(where: { $0.bookId == book.bookId}) {
                backupBooks[index] = book
            }
        }
        await state?.replaceBooks(books: allBooks)
        await state?.replaceBackupBooks(books: backupBooks)
    }
    
    nonisolated private func _observeDeleted(from ids: [PersistentIdentifier]) async  {
        guard !ids.isEmpty else { return }
        await state?.removeBooks(byPersistentIdentifiers: ids)
    }
}
