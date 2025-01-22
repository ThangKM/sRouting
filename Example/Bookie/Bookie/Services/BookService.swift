//
//  BookService.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//
import SwiftData
import Foundation

@DatabaseActor
final class BookService {
    
    func isDatabaseEmpty() -> Bool {
        let context = ModelContext.isolatedContext
        let count = (try? context.fetchCount(BookPersistent.fetchAll)) ?? .zero
        return count == .zero
    }
    
    func generateBooks(count: Int) async throws {
        let books = await MockBookService.shared.generateBooks(count: count)
        try await _addNewOrUpdate(fromBooks: books)
    }
    
    func fetchAllBooks(offset: Int, limit: Int, sortBy: [SortDescriptor<BookPersistent>]) async throws -> [BookModel] {
        let context = ModelContext.isolatedContext
        let books = try context.fetch(BookPersistent.fetch(offset: offset, limit: limit, sortBy: sortBy))
        let models = books.map { BookModel(persistentModel: $0) }
        return models
    }
    
    func updateBook(_ book: BookModel) async throws {
        let context = ModelContext.isolatedContext
        let books = try context.fetch(BookPersistent.fetchByBookId(book.id))
        guard let persistentBook = books.first else {
            return
        }
        persistentBook.rating = book.rating
        persistentBook.name = book.name
        persistentBook.author = book.author
        persistentBook.bookDescription = book.description
        persistentBook.imageName = book.imageName
        
        try await databaseUpdateTransaction(models: [persistentBook], useContext: context)
    }
    
    func books(fromPersistentIdentifiers ids: [PersistentIdentifier]) -> [BookModel] {
        let context = ModelContext.isolatedContext
        let bookPersistents = (try? context.fetch(BookPersistent.fetchByIdentifiers(ids.unique()))) ?? []
        let books = bookPersistents.map({ BookModel(persistentModel: $0) })
        return books
    }
    
    func deleteBooks(byPersistentIdentifiers ids: [PersistentIdentifier]) async throws {
        let context = ModelContext.isolatedContext
        var books = [BookPersistent]()
        for id in ids {
            guard let book = context.model(for: id) as? BookPersistent
            else { continue }
            books.append(book)
        }
        try await databaseDeleteTransaction(models: books, useContext: context)
    }
    
    func searchBooks(query: String) throws -> [BookModel] {
        let context = ModelContext.isolatedContext
        let books = try context.fetch(BookPersistent.searchBook(query: query))
        let result = books.map { BookModel(persistentModel: $0) }
        return result
    }
}

extension BookService {
    
    private func _addNewOrUpdate(fromBooks books: [BookModel]) async throws {
       
        let context = ModelContext.isolatedContext
        let bookIds = books.map(\.bookId).unique()
        let updateModels = try context.fetch(BookPersistent.fetchByBookIds(bookIds))
        var insertModels: [BookPersistent] = []
        let count = books.count
        for book in books {
            autoreleasepool {
                if let model = updateModels.first(where: { book.bookId == $0.bookId }) {
                    model.update(with: book)
                } else {
                    insertModels.append(.init(book: book))
                }
            }
            try? await prevent_huge_loop(count: count)
        }
        
        try await databaseUpdateTransaction(models: updateModels, useContext: context)
        try await databaseInsertTransaction(models: insertModels, useContext: context)
    }
}

extension Array where Element: Hashable {
    
    func unique() -> Set<Element> {
        Set(self)
    }
}
