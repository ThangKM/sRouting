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
    
    func isDatabaseEmpty() async -> Bool {
        let context = ModelContext.fetchContext
        let count = (try? context.fetchCount(BookPersistent.fetchAll)) ?? .zero
        return count == .zero
    }
    
    func fetchAllBooks(nextToken: FetchNextToken<BookPersistent>?) async throws -> FetchResult<BookModel, BookPersistent> {
        let context = ModelContext.fetchContext
        let descriptor: FetchDescriptor<BookPersistent>
        if let nextToken {
            descriptor = nextToken.descriptor
        } else {
            descriptor = BookPersistent.fetch(offset: .zero, limit: 20, sortBy: [.init(\.bookId, order: .forward)])
        }
        try Task.checkCancellation()
        let books = try context.fetch(descriptor)
        let models = books.map { BookModel(persistentModel: $0) }
        let result = FetchResult(models: models, nextToken: .init(identifier: "fetchAllBooks",
                                                                  descriptor: descriptor.next(previousItemCount: books.count)))
        try Task.checkCancellation()
        return result
    }
    
    func books(fromPersistentIdentifiers ids: [PersistentIdentifier]) async -> [BookModel] {
        let context = ModelContext.fetchContext
        let bookPersistents = (try? context.fetch(BookPersistent.fetchByIdentifiers(ids.unique()))) ?? []
        let books = bookPersistents.map({ BookModel(persistentModel: $0) })
        return books
    }
    
    func searchBooks(query: String, nextToken: FetchNextToken<BookPersistent>?) async throws -> FetchResult<BookModel, BookPersistent> {
        guard !query.isEmpty else { return .init() }
        let context = ModelContext.fetchContext
        let descriptor: FetchDescriptor<BookPersistent>
        if let nextToken {
            descriptor = nextToken.descriptor
        } else {
            descriptor = BookPersistent.searchBook(query: query)
        }
        try Task.checkCancellation()
        let books = try context.fetch(descriptor)
        let sendableModel = books.map { BookModel(persistentModel: $0) }
        let nextDescriptor = descriptor.next(previousItemCount: books.count)
        let result = FetchResult(models: sendableModel, nextToken: .init(identifier: query, descriptor: nextDescriptor))
        try Task.checkCancellation()
        return result
    }
}

//MARK: - Make Changes
extension BookService {
    
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
    
    @DatabaseActor
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
