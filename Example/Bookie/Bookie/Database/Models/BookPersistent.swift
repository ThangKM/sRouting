//
//  BookPersistent.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import SwiftData
import Foundation
import ModelSendable

@Model @ModelSendable(name: "BookModel")
final class BookPersistent {

    @Attribute(.unique)
    var bookId: Int
    var name: String
    var imageName: String
    var author :String
    var bookDescription: String
    var rating: Int
    var raingMapping: [Int: Int] = [Int: Int]()
    var newItem: [Int] = []
    
    init(bookId: Int,
         name: String,
         imageName: String,
         author: String,
         bookDescription: String,
         rating: Int) {
        self.bookId = bookId
        self.name = name
        self.imageName = imageName
        self.author = author
        self.bookDescription = bookDescription
        self.rating = rating
        self.raingMapping = [bookId: rating]
    }
    
    init(sendable: BookModel) {
        self.bookId = sendable.bookId
        self.name = sendable.name
        self.imageName = sendable.imageName
        self.author = sendable.author
        self.bookDescription = sendable.bookDescription
        self.rating = sendable.rating
        self.raingMapping = sendable.raingMapping
    }
}

extension BookPersistent.BookModel: Hashable, Identifiable {
    
    var id: Int { bookId }
    
    static func == (lhs: BookPersistent.BookModel, rhs: BookPersistent.BookModel) -> Bool {
        return lhs.persistentIdentifier == rhs.persistentIdentifier &&
        lhs.bookId == rhs.bookId &&
        lhs.name == rhs.name &&
        lhs.imageName == rhs.imageName &&
        lhs.author == rhs.author &&
        lhs.bookDescription == rhs.bookDescription &&
        lhs.rating == rhs.rating
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(persistentIdentifier)
        hasher.combine(bookId)
    }
}
