//
//  BookService.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//
import SwiftData
import Foundation


//MARK: - Fetch Only
final class BookService: Sendable {
    
    let queries = BookPersistent.Query()
    
    func isDatabaseEmpty() async -> Bool {
        let context = ModelContext.fetchContext
        let count = (try? context.fetchCount(queries.fetchAll)) ?? .zero
        return count == .zero
    }
    
    func fetchAllBooks(nextToken: FetchNextToken<BookPersistent>?) async throws -> FetchResult<BookPersistent> {
        let context = ModelContext.fetchContext
        let descriptor: FetchDescriptor<BookPersistent>
        if let nextToken {
            descriptor = nextToken.descriptor
        } else {
            descriptor = queries.fetch(offset: .zero, limit: 20, sortBy: [.init(\.bookId, order: .forward)])
        }
        try Task.checkCancellation()
        let books = try context.fetch(descriptor)
        let models = books.map(\.sendable)
        let result = FetchResult(models: models, nextToken: .init(identifier: "fetchAllBooks",
                                                                  descriptor: descriptor.next(previousItemCount: books.count)))
        try Task.checkCancellation()
        return result
    }
    
    func books(fromPersistentIdentifiers ids: [PersistentIdentifier]) async -> [BookPersistent.SendableType] {
        let context = ModelContext.fetchContext
        let bookPersistents = (try? context.fetch(queries.fetchByIdentifiers(ids.unique()))) ?? []
        let books = bookPersistents.map(\.sendable)
        return books
    }
    
    func searchBooks(query: String, nextToken: FetchNextToken<BookPersistent>?) async throws -> FetchResult<BookPersistent> {
        guard !query.isEmpty else { return .init() }
        let context = ModelContext.fetchContext
        let descriptor: FetchDescriptor<BookPersistent>
        if let nextToken {
            descriptor = nextToken.descriptor
        } else {
            descriptor = queries.searchBook(query: query)
        }
        try Task.checkCancellation()
        let books = try context.fetch(descriptor)
        let sendableModel = books.map(\.sendable)
        let nextDescriptor = descriptor.next(previousItemCount: books.count)
        let result = FetchResult(models: sendableModel, nextToken: .init(identifier: query, descriptor: nextDescriptor))
        try Task.checkCancellation()
        return result
    }
}

//MARK: - Make Changes
extension BookService {
    
    @DatabaseActor
    func deleteAll() async throws {
        let context = ModelContext.isolatedContext
        let books = try context.fetch(queries.fetchAll)
        try await databaseDeleteTransaction(models: books, useContext: context)
    }
    
    @DatabaseActor
    func generateBooks(count: Int) async throws {
        let books = await MockBookService.shared.generateBooks(count: count)
        try await _addNewOrUpdate(fromBooks: books)
    }
    
    @DatabaseActor
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
    
    @DatabaseActor
    func updateBook(_ book: BookPersistent.SendableType) async throws {
        let context = ModelContext.isolatedContext
        let books = try context.fetch(queries.fetchByBookId(book.bookId))
        guard let persistentBook = books.first else {
            return
        }
        persistentBook.update(from: book)
        try await databaseUpdateTransaction(models: [persistentBook], useContext: context)
    }
    
    @DatabaseActor
    private func _addNewOrUpdate(fromBooks books: [BookPersistent.SendableType]) async throws {
       
        let context = ModelContext.isolatedContext
        let bookIds = books.map(\.bookId).unique()
        let updateModels = try context.fetch(queries.fetchByBookIds(bookIds))
        var insertModels: [BookPersistent] = []
        let count = books.count
        for book in books {
            autoreleasepool {
                if let model = updateModels.first(where: { book.bookId == $0.bookId }) {
                    model.update(from: book)
                } else {
                    insertModels.append(.init(sendable: book))
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
