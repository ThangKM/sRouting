//
//  MockBookData.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import Foundation

@MainActor
final class MockBookData: ObservableObject {
    
    @Published
    private(set) var books: [BookModel] = [
        .init(id: 1,
              name: "The Fountainhead",
              imageName: "book_cover_fountainhead",
              author: "Ayn Rand",
              description: """
 The Fountainhead is a 1943 novel by Russian-American author Ayn Rand, her first major literary success. The novel's protagonist, Howard Roark, is an intransigent young architect, who battles against conventional standards and refuses to compromise with an architectural establishment unwilling to accept innovation. Roark embodies what Rand believed to be the ideal man, and his struggle reflects Rand's belief that individualism is superior to collectivism.
 """,
              rating: 5)
    ]
}


extension MockBookData {
    func updateBook(book: BookModel) {
        guard  let old = books.first(where: { $0.id == book.id }),
               let index = books.firstIndex(of: old)
        else { return }
        books[index] = book
    }
}
