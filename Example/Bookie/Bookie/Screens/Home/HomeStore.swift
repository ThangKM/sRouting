//
//  HomeStore.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

//MARK: - HomeState
extension HomeScreen {
    
    @Observable @MainActor
    final class HomeState {
        
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
    }
    
    enum HomeAction: Sendable {
        case fetchAllBooks
        case findBooks(text: String)
        case gotoDetail(book: BookModel)
    }
}

//MARK: - HomeStore
extension HomeScreen {
    
    final class HomeStore: ActionStore {
        
        private weak var state: HomeState?
        private weak var bookService: MockBookService?
        private weak var router: SRRouter<HomeRoute>?
        
        func binding(state: HomeState) {
            self.state = state
        }
        
        func binding(bookService: MockBookService, router: SRRouter<HomeRoute>) {
            self.bookService = bookService
            self.router = router
        }
        
        func receive(action: HomeAction) {
            assert((state != nil && bookService != nil && router != nil) || EnvironmentRunner.current == .livePreview, "Need binding state, router and book service")
            
            switch action {
            case .fetchAllBooks:
                state?.updateAllBooks(books: bookService?.books ?? [])
            case .findBooks(let text):
                _findBooks(withText: text)
            case .gotoDetail(let book):
                router?.trigger(to: .bookDetailScreen(book: book), with: .allCases.randomElement() ?? .push)
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
}

