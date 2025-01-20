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
        
        private(set) var nothingToLoadMore: Bool = true
        
        private(set) var books: [BookModel] = []
        
        private var backupBooks: [BookModel] = []
        
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
        
        func updateNothingToLoadMore(nothingToLoadMore: Bool) {
            self.nothingToLoadMore = nothingToLoadMore
        }
    }
    
    enum HomeAction: Sendable {
        case firstFetchBooks
        case refreshBooks
        case loadmoreBooks
        case findBooks(text: String)
        case gotoDetail(book: BookModel)
    }
}

//MARK: - HomeStore
extension HomeScreen {
    
    final class HomeStore: ActionStore {
        
        private weak var state: HomeState?
        private weak var router: SRRouter<HomeRoute>?
        private let cancelBag = CancelBag()
        private var didObserveChanges: Bool = false
        private lazy var fetchPagingService: FetchPagingService<BookPersistent> = .init(sortBy: [.init(\.id, order: .forward)])
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
            case .refreshBooks:
                _refreshBooks()
            case .loadmoreBooks:
                _loadmoreBooks()
            case .firstFetchBooks:
                _firstFetchAllBooks()
            case .findBooks(let text):
                _findBooks(withText: text)
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
    
    private func _findBooks(withText text: String) {
        
        guard !text.isEmpty else {
            state?.restoreListBooks()
            return
        }
        
        Task {
            let books = try await bookService.searchBooks(query: text)
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
            state?.updateNothingToLoadMore(nothingToLoadMore: books.count < fetchPagingService.limit)
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
    
    private func _observeBookChanges() {
        guard !didObserveChanges else { return }
        didObserveChanges = true
        Task.detached {[weak self] in
            guard let self else { return }
            let stream = await DatabaseActor.shared.stream
            try Task.checkCancellation()
            for await result in stream {
                switch result {
                case .addNewOrUpdate(let ids):
                    await self._updateBooks(from: ids)
                default: break
                }
            }
        }.store(in: cancelBag, withIdentifier: "HommeStore.observeBookChanges")
    }
    
    nonisolated private func _updateBooks(from ids: [PersistentIdentifier]) async  {
        let books = (try? await bookService.books(from: ids)) ?? []
        guard !books.isEmpty else { return }
        var allBooks = (await state?.books) ?? []
        guard !allBooks.isEmpty else { return }
        for book in books {
            if let index = await state?.books.firstIndex(where: { $0.id == book.id}) {
                allBooks[index] = book
            } else {
                allBooks.insert(book, at: .zero)
            }
        }
        await state?.replaceBooks(books: allBooks)
        await state?.updateNothingToLoadMore(nothingToLoadMore: false)
        await _findBooks(withText: state?.seachText ?? "")
    }
}

