//
//  HomeState.swift
//  Bookie
//
//  Created by Thang Kieu on 23/1/25.
//

import SwiftUI
import SwiftData

//MARK: - HomeState
extension HomeScreen {
    
    @Observable
    final class HomeState: ScreenStates {
        
        @ObservationIgnored
        private var _searchText: String = ""
        
        var seachText: String {
            get {
                access(keyPath: \.seachText)
                return _searchText
            }
            
            set {
                let newText = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard newText != _searchText else { return }
                withMutation(keyPath: \.seachText) {
                    _searchText = newText
                }
            }
        }
        
        private(set) var books: [BookPersistent.SendableType] = []
        private(set) var isLoadingMore: Bool = false
        
        @ObservationIgnored
        private(set) var backupBooks: [BookPersistent.SendableType] = []
    }
}

//MARK: - Update Actions
extension HomeScreen.HomeState {
    
    func updateLoadmore(isLoadingMore: Bool) {
        self.isLoadingMore = isLoadingMore
    }
    
    func appendAllBooks(books: [BookPersistent.SendableType]) {
        self.books.append(contentsOf: books)
    }
    
    func repaceAndBackupListBooks(books: [BookPersistent.SendableType]) {
        
        switch true {
        case backupBooks.isEmpty && !books.isEmpty && !_searchText.isEmpty: // backup list before show search result
            backupBooks = self.books
            self.books = books
        case _searchText.isEmpty && books.isEmpty: // end searching, restore books.
            self.books = backupBooks
            backupBooks = []
        default: // searching
            withAnimation {
                self.books = books
            }
        }
    }
    
    func replaceBooks(books: [BookPersistent.SendableType]) {
        self.books = books
    }
    
    func insertNewBoosk(_ books: [BookPersistent.SendableType]) {
        guard !books.isEmpty else { return }
        if _searchText.isEmpty {
            withAnimation {
                self.books.insert(contentsOf: books, at: .zero)
            }
        } else {
            self.backupBooks.insert(contentsOf: books, at: .zero)
        }
    }
    
    func updateBooks(_ books: [BookPersistent.SendableType]) {
        
        let displayBooks = self.books
        let backup = self.backupBooks
        
        for book in books {
            if let index = displayBooks.firstIndex(where: {$0.bookId == book.bookId }) {
                self.books[index] = book
            }
            guard !backup.isEmpty else { continue }
            if let index = backup.firstIndex(where: {$0.bookId == book.bookId }) {
                backupBooks[index] = book
            }
        }
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
                ids.contains($0.persistentIdentifier)
            })
        }
    }
}
