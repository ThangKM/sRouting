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
        
        private(set) var isLoading = false
        
        @ObservationIgnored
        private(set) var book: BookPersistent.SendableType
        
        init(book: BookPersistent.SendableType) {
            self.book = book
        }
        
        func updateLoading(_ isLoading: Bool) {
            self.isLoading = isLoading
        }
    }
    
    enum DetailAction: Sendable {
        case deleteBook
        case saveBook
        case stressTest
    }
}

//MARK: - DetailStore
extension BookDetailScreen {
    
    final class DetailStore: ActionStore {
        
        private weak var state: DetailState?
        private weak var router: SRRouter<HomeRoute>?
        
        private lazy var bookService = BookService()
        
        func binding(state: DetailState, router: SRRouter<HomeRoute>?) {
            self.state = state
            self.router = router
        }
    
        func receive(action: DetailAction) {
            assert(state != nil, "Missing binding state or book service")
            switch action {
            case .saveBook:
                guard let book = state?.book else { return }
                _saveBook(book)
            case .deleteBook:
                _confirmDeleteBook()
            case .stressTest:
                _stressTest()
            }
        }
    }
}

//MARK: - Private Jobs
extension BookDetailScreen.DetailStore {
    
    func _stressTest() {
        Task {
            try await bookService.generateBooks(count: 100_000)
        }
    }
    
    func _saveBook(_ book: BookPersistent.SendableType) {
        Task {
            try await bookService.updateBook(book)
        }
    }
    
    func _confirmDeleteBook() {
        router?.show(dialog: .delete(confirmedAction: {[weak self] in
            self?._deleteBook()
        }))
    }
    
    func _deleteBook() {
        Task {
            guard let persistentId = state?.book.persistentIdentifier else { return }
            do {
                state?.updateLoading(true)
                try await bookService.deleteBooks(byPersistentIdentifiers: [persistentId])
                router?.dismiss()
                state?.updateLoading(false)
            } catch {
                state?.updateLoading(false)
            }
        }
    }
}
