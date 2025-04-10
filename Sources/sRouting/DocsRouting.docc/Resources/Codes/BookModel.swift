//
//  BookModel.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import Foundation

struct BookModel: Identifiable, Sendable {
    let id: Int
    let name: String
    let imageName: String
    let author :String
    let description: String
    var rating: Int
}

extension BookModel: Equatable {
    static func == (lhs: BookModel, rhs: BookModel) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.imageName == rhs.imageName &&
        lhs.author == rhs.author &&
        lhs.description == rhs.description &&
        lhs.rating == rhs.rating
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
