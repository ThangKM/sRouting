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
    var id: Int
    @Attribute(.spotlight)
    var name: String
    var imageName: String
    @Attribute(.spotlight)
    var author :String
    var bookDescription: String
    var rating: Int
    
    init(id: Int, name: String, imageName: String, author: String, bookDescription: String, rating: Int) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.author = author
        self.bookDescription = bookDescription
        self.rating = rating
    }
    
    init (book: BookModel) {
        self.id = book.id
        self.name = book.name
        self.imageName = book.imageName
        self.author = book.author
        self.bookDescription = book.description
        self.rating = book.rating
    }
}

//MARK: - Fetch Descriptor
extension BookPersistent {
    static var fetchAll: FetchDescriptor<BookPersistent> {
        .init()
    }
    
    static func fetchById(_ id: Int) -> FetchDescriptor<BookPersistent> {
        .init(predicate: #Predicate { $0.id == id })
    }
}
