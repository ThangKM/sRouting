//
//  BookModel.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import Foundation
import SwiftData

struct BookModel: Identifiable, Sendable {
    var id: Int { bookId }
    var bookId: Int
    var persistentIdentifier: PersistentIdentifier?
    let name: String
    let imageName: String
    let author :String
    let description: String
    var rating: Int
    
    init (bookId: Int, name: String, imageName: String, author: String, description: String, rating: Int) {
        self.bookId = bookId
        self.name = name
        self.imageName = imageName
        self.author = author
        self.description = description
        self.rating = rating
    }
    
    init(persistentModel: BookPersistent) {
        self.bookId = persistentModel.bookId
        self.name = persistentModel.name
        self.imageName = persistentModel.imageName
        self.author = persistentModel.author
        self.description = persistentModel.bookDescription
        self.rating = persistentModel.rating
        self.persistentIdentifier = persistentModel.id
    }
}

extension BookModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bookId)
        hasher.combine(persistentIdentifier)
    }
    
    static func == (lhs: BookModel, rhs: BookModel) -> Bool {
        return lhs.bookId == rhs.bookId &&
        lhs.persistentIdentifier == rhs.persistentIdentifier &&
        lhs.name == rhs.name &&
        lhs.imageName == rhs.imageName &&
        lhs.author == rhs.author &&
        lhs.description == rhs.description &&
        lhs.rating == rhs.rating
    }
}

extension BookModel: EmptyObjectType {
    
    static var empty: BookModel {
        .init(bookId: -999,
            name: "",
            imageName: "",
            author: "",
            description: "",
            rating: 0)
    }
    
    var isEmptyObject: Bool { bookId == -999 }
}
