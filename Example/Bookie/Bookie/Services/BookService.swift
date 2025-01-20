//
//  BookService.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//
import SwiftData

@PersistentActor
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
        try await persistentWriteTransaction(models: models, useContext: .init(container))
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
        try await persistentWriteTransaction(models: [persistentBook], useContext: context)
    }
}
