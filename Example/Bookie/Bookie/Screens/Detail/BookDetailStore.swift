//
//  BookDetailViewModel.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import SwiftUI
import sRouting

//MARK: - DetailState
extension BookDetailScreen {
    
    @Observable @MainActor
    final class DetailState: Sendable {
        
        var rating: Int {
            get {
                access(keyPath: \.rating)
                return book.rating
            }
            set {
                withMutation(keyPath: \.rating) {
                    book.rating = newValue
                }
            }
        }
        
        @ObservationIgnored
        private(set) var book: BookModel
        
        init(book: BookModel) {
            self.book = book
        }
    }
    
    enum DetailAction: Sendable {
        case saveBook
    }
}

//MARK: - DetailStore
extension BookDetailScreen {
    
    final class DetailStore: ActionStore {
        
        private weak var state: DetailState?
        private weak var bookService: MockBookService?
        
        func binding(state: DetailState) {
            self.state = state
        }
        
        func binding(bookService: MockBookService) {
            self.bookService = bookService
        }
        
        func receive(action: DetailAction) {
            switch action {
            case .saveBook:
                guard let book = state?.book else { return }
                bookService?.updateBook(book: book)
            }
        }
    }
}

