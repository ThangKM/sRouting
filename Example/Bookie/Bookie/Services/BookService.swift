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
    
    private let container: ModelContainer = DatabaseProvider.shared.container
    
    func isDatabaseEmpty() -> Bool {
        let context = ModelContext(container)
        let count = (try? context.fetchCount(BookPersistent.fetchAll)) ?? .zero
        return count == .zero
    }
    
    func generateBooks(count: Int) async throws {
        let books = await MockBookService.shared.generateBooks(count: count)
        let models = books.map({ BookPersistent(book: $0) })
        try await databaseWriteTransaction(models: models, useContext: .init(container))
    }
    
    func fetchAllBooks(offset: Int, limit: Int, sortBy: [SortDescriptor<BookPersistent>]) async throws -> [BookModel] {
        let context = ModelContext(container)
        let books = try context.fetch(BookPersistent.fetch(offset: offset, limit: limit, sortBy: sortBy))
        let models = books.map { BookModel(persistentModel: $0) }
        return models
    }
    
    func updateBook(_ book: BookModel) async throws {
        let context = ModelContext(container)
        let books = try context.fetch(BookPersistent.fetchByBookId(book.id))
        guard let persistentBook = books.first else {
            return
        }
        persistentBook.rating = book.rating
        persistentBook.name = book.name
        persistentBook.author = book.author
        persistentBook.bookDescription = book.description
        persistentBook.imageName = book.imageName
        try await databaseWriteTransaction(models: [persistentBook], useContext: context)
    }
    
    func books(fromPersistentIdentifiers ids: [PersistentIdentifier]) -> [BookModel] {
        let context = ModelContext(container)
        var books = [BookModel]()
        for id in ids {
            guard let book = context.model(for: id) as? BookPersistent
            else { continue }
            books.append(.init(persistentModel: book))
        }
        return books
    }
    
    func deleteBooks(byPersistentIdentifiers ids: [PersistentIdentifier]) async throws {
        let context = ModelContext(container)
        var books = [BookPersistent]()
        for id in ids {
            guard let book = context.model(for: id) as? BookPersistent
            else { continue }
            books.append(book)
        }
        try await databaseDeleteTransaction(models: books, useContext: context)
    }
    
    func searchBooks(query: String) throws -> [BookModel] {
        let context = ModelContext(container)
        let books = try context.fetch(BookPersistent.searchBook(query: query))
        let result = books.map { BookModel(persistentModel: $0) }
        return result
    }
}
