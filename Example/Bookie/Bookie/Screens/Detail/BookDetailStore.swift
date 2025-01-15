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
    
    final class DetailStore: ViewStore {
        
        private weak var state: DetailState?
        private weak var mockData: MockBookData?
        
        func binding(state: DetailState) {
            self.state = state
        }
        
        func binding(mockData: MockBookData) {
            self.mockData = mockData
        }
        
        func receive(action: DetailAction) {
            switch action {
            case .saveBook:
                guard let book = state?.book else { return }
                mockData?.updateBook(book: book)
            }
        }
    }
}

