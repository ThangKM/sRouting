//
//  BookPersistent.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import SwiftData
import Foundation

@Model
final class BookPersistent {

    @Attribute(.unique)
    var bookId: Int
    @Attribute(.spotlight)
    var name: String
    var imageName: String
    @Attribute(.spotlight)
    var author :String
    var bookDescription: String
    var rating: Int
    
    init (book: BookModel) {
        self.bookId = book.bookId
        self.name = book.name
        self.imageName = book.imageName
        self.author = book.author
        self.bookDescription = book.description
        self.rating = book.rating
    }
}

//MARK: - FetchDescriptors
extension BookPersistent {
    static var fetchAll: FetchDescriptor<BookPersistent> {
        .init()
    }
    
    static func fetchByBookId(_ id: Int) -> FetchDescriptor<BookPersistent> {
        .init(predicate: #Predicate { $0.bookId == id })
    }
    
    static func fetch(offset: Int, limit: Int, sortBy: [SortDescriptor<BookPersistent>]) -> FetchDescriptor<BookPersistent> {
        var fetchDescriptor = fetchAll
        fetchDescriptor.fetchOffset = offset
        fetchDescriptor.fetchLimit = limit
        fetchDescriptor.sortBy = sortBy
        return fetchDescriptor
    }
    
    static func searchBook(query: String) -> FetchDescriptor<BookPersistent> {
        .init(predicate: #Predicate { $0.name.localizedStandardContains(query)
            || $0.author.localizedStandardContains(query) })
    }
}
