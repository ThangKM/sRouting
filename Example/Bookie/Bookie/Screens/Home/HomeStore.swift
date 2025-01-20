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
        
        init() {
            print("init HomeState")
        }
        
        var seachText: String = ""
        
        private(set) var books: [BookModel] = []
        
        @ObservationIgnored
        private(set) var allBooks: [BookModel] = []
        
        func updateAllBooks(books: [BookModel]) {
            self.allBooks = books
            guard self.books.isEmpty else { return }
            self.books = books
        }
        
        func updateBooks(books: [BookModel]) {
            withAnimation {
                self.books = books
            }
        }
        
        deinit {
            print("Deinit HomeState")
        }
    }
    
    enum HomeAction: Sendable {
        case fetchAllBooks(isRefresh: Bool)
        case findBooks(text: String)
        case gotoDetail(book: BookModel)
    }
}

//MARK: - HomeStore
extension HomeScreen {
    
    final class HomeStore: ActionStore {
        
        private weak var state: HomeState?
        private weak var router: SRRouter<HomeRoute>?
        private lazy var bookService: BookService = .init()

        func binding(state: HomeState, router: SRRouter<HomeRoute>) {
            self.state = state
            self.router = router
        }
        
        func receive(action: HomeAction) {
            assert((state != nil && router != nil) || EnvironmentRunner.current == .livePreview, "Need binding state, router and book service")
            
            switch action {
            case .fetchAllBooks(let isRefresh):
                _fetchAllBooks(isRefresh: isRefresh)
            case .findBooks(let text):
                _findBooks(withText: text)
            case .gotoDetail(let book):
                router?.trigger(to: .bookDetailScreen(book: book), with: .push)
            }
        }
    }
}

//MARK: - Private Jobs
extension HomeScreen.HomeStore {
    
    private func _findBooks(withText text: String) {
        
        guard !text.isEmpty else {
            state?.updateBooks(books: state?.allBooks ?? [])
            return
        }
        
        let books =  state?.allBooks.filter { $0.name.lowercased().contains(text.lowercased())
            || $0.author.lowercased().contains(text.lowercased()) } ?? []
        state?.updateBooks(books: books)
    }
    
    private func _fetchAllBooks(isRefresh: Bool) {
        guard let state else { return }
        guard isRefresh || state.allBooks.isEmpty else { return }
        Task {
            let books = try await bookService.fetchAllBooks()
            state.updateAllBooks(books: books)
        }
    }
}

