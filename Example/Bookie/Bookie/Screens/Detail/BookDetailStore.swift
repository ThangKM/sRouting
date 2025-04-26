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
    
    @Observable
    final class DetailState: ScreenStates {
        
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
        private(set) var book: BookPersistent.SendableType
        
        init(book: BookPersistent.SendableType) {
            self.book = book
            super.init()
        }
    }
    
    enum DetailAction: Sendable, ActionLockable {
        case deleteBook
        case saveBook
        case stressTest
        case deleteAll
    }
}

//MARK: - DetailStore
extension BookDetailScreen {
    
    actor DetailStore: ActionStore {
        
        private weak var state: DetailState?
        private weak var router: SRRouter<HomeRoute>?
        
        private lazy var bookService = BookService()
        private let actionLocker = ActionLocker()
        
        func binding(state: DetailState) {
            self.state = state
        }
        
        func binding(router: SRRouter<HomeRoute>) {
            self.router = router
        }
    
        nonisolated func receive(action: DetailAction) {
            Task {
                guard await actionLocker.canExecute(action) else { return }
                switch action {
                case .saveBook:
                    guard let book = await state?.book else { return }
                    await _saveBook(book)
                case .deleteBook:
                    await _confirmDeleteBook()
                case .stressTest:
                    await _stressTest()
                case .deleteAll:
                    await _deleteAllBooks()
                }
                await actionLocker.unlock(action)
            }
        }
    }
}

//MARK: - Private Jobs
extension BookDetailScreen.DetailStore {
    
    func _deleteAllBooks() {
        Task {
            try await bookService.deleteAll()
        }
    }
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
    
    func _confirmDeleteBook() async {
        await router?.show(dialog: .delete(confirmedAction: {[weak self] in
            Task {
                try await self?._deleteBook()
            }
        }))
    }
    
    func _deleteBook() async throws {
        guard let persistentId = await state?.book.persistentIdentifier else { return }
        try await bookService.deleteBooks(byPersistentIdentifiers: [persistentId])
        await router?.dismiss()
    }
}
