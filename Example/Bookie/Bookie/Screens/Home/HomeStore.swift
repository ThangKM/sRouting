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
            self.books = books
        }
    }
    
    enum HomeAction: Sendable {
        case updateAllBooks(books: [BookModel])
        case findBooks(text: String)
    }
}

//MARK: - HomeStore
extension HomeScreen {
    
    final class HomeStore: ViewStore {
        
        private weak var state: HomeState?

        func binding(state: HomeState) {
            self.state = state
        }
        
        func receive(action: HomeAction) {
            switch action {
            case .updateAllBooks(let books):
                state?.updateAllBooks(books: books)
            case .findBooks(let text):
                _findBooks(withText: text)
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

