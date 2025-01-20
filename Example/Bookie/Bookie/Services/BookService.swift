//
//  BookService.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//
import SwiftData

@DatabaseActor
final class BookService {
    
    private let container: ModelContainer = Database.shared.container
    
    func isDatabaseEmpty() -> Bool {
        let context = ModelContext(container)
        let count = (try? context.fetchCount(BookPersistent.fetchAll)) ?? .zero
        return count == .zero
    }
    
    func synchronizeBooksFromMockData() async throws {
        let books = MockBookService().books
        let models = books.map({ BookPersistent(book: $0) })
        try await databaseWriteTransaction(models: models, useContext: .init(container))
    }
    
    func fetchAllBooks() async throws -> [BookModel] {
        let context = ModelContext(container)
        let books = try context.fetch(BookPersistent.fetchAll)
        let models = books.map { BookModel(persistentModel: $0) }
        return models
    }
    
    func updateBook(_ book: BookModel) async throws {
        let context = ModelContext(container)
        let books = try context.fetch(BookPersistent.fetchById(book.id))
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
    
    func books(from ids: [PersistentIdentifier]) async throws -> [BookModel] {
        let context = ModelContext(container)
        
        var books = [BookModel]()
        for id in ids {
            guard let book = context.model(for: id) as? BookPersistent
            else { continue }
            books.append(.init(persistentModel: book))
        }
        return books
    }
}
