//
//  BookModel.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import Foundation

struct BookModel: Identifiable, Sendable {
    var id: Int
    let name: String
    let imageName: String
    let author :String
    let description: String
    var rating: Int
    
    init (id: Int, name: String, imageName: String, author: String, description: String, rating: Int) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.author = author
        self.description = description
        self.rating = rating
    }
    
    init(persistentModel: BookPersistent) {
        self.id = persistentModel.id
        self.name = persistentModel.name
        self.imageName = persistentModel.imageName
        self.author = persistentModel.author
        self.description = persistentModel.bookDescription
        self.rating = persistentModel.rating
    }
}

extension BookModel: EmptyObjectType {
    
    static var empty: BookModel {
        .init(id: -999,
            name: "",
            imageName: "",
            author: "",
            description: "",
            rating: 0)
    }
    
    var isEmptyObject: Bool { id == -999 }
}
