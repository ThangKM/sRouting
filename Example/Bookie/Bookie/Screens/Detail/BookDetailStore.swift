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
        private lazy var bookService = BookService()
        
        func binding(state: DetailState) {
            self.state = state
        }
    
        func receive(action: DetailAction) {
            assert(state != nil, "Missing binding state or book service")
            switch action {
            case .saveBook:
                guard let book = state?.book else { return }
                _saveBook(book)
            }
        }
    }
}


extension BookDetailScreen.DetailStore {
    
    func _saveBook(_ book: BookModel) {
        Task {
            try await bookService.updateBook(book)
        }
    }
}
