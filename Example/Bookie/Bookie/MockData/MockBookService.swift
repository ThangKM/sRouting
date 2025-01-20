//
//  MockBookData.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import Foundation
import Observation
import SwiftUI

final class MockBookService: Sendable {
    static let shared = MockBookService()
    private init() {}
    
    func generateBooks(count: Int) async -> [BookModel] {
        let books = self.books
        var result: [BookModel] = []
        
        for id in 1...count {
            guard var book = books.randomElement() else { continue }
            book.id = id
            result.append(book)
        }
        return result
    }
}

extension MockBookService {
    
    var book: BookModel {
        .init(id: 1,
              name: "The Fountainhead",
              imageName: "book_cover_fountainhead",
              author: "Ayn Rand",
              description: """
 The Fountainhead is a 1943 novel by Russian-American author Ayn Rand, her first major literary success. The novel's protagonist, Howard Roark, is an intransigent young architect, who battles against conventional standards and refuses to compromise with an architectural establishment unwilling to accept innovation. Roark embodies what Rand believed to be the ideal man, and his struggle reflects Rand's belief that individualism is superior to collectivism.
 """, rating: 5)
    }
    
    var books: [BookModel] {
        [
            .init(id: 1,
                  name: "The Fountainhead",
                  imageName: "book_cover_fountainhead",
                  author: "Ayn Rand",
                  description: """
     The Fountainhead is a 1943 novel by Russian-American author Ayn Rand, her first major literary success. The novel's protagonist, Howard Roark, is an intransigent young architect, who battles against conventional standards and refuses to compromise with an architectural establishment unwilling to accept innovation. Roark embodies what Rand believed to be the ideal man, and his struggle reflects Rand's belief that individualism is superior to collectivism.
     """, rating: 5),
            .init(id: 2, name: "The Godfather", imageName: "book_cover_godfather", author: "Mario Puzo", description: """
    The Godfather is a 1972 American crime film directed by Francis Ford Coppola, who co-wrote the screenplay with Mario Puzo, based on Puzo's best-selling 1969 novel of the same name. The film stars Marlon Brando, Al Pacino, James Caan, Richard Castellano, Robert Duvall, Sterling Hayden, John Marley, Richard Conte, and Diane Keaton. It is the first installment in The Godfather trilogy. The story, spanning from 1945 to 1955, chronicles the Corleone family under patriarch Vito Corleone (Brando), focusing on the transformation of his youngest son, Michael Corleone (Pacino), from reluctant family outsider to ruthless mafia boss.
    """, rating: 5),
            .init(id: 3, name: "Red Dragon", imageName: "book_cover_red_dragon", author: "Thomas Harris", description: """
        Red Dragon is a novel by American author Thomas Harris, first published in 1981. The plot follows former FBI profiler Will Graham, who comes out of retirement to find and apprehend an enigmatic serial-killer nicknamed "The Tooth Fairy". The novel introduced the character Dr. Hannibal Lecter, a brilliant psychiatrist and cannibalistic serial-killer, whom Graham reluctantly turns to for advice and with whom he has a dark past. The title refers to the figure from William Blake's painting The Great Red Dragon and the Woman Clothed in Sun.
        """,
                  rating: 5),
            .init(id: 4, name: "Hannibal", imageName: "book_cover_hannibal", author: "Thomas Harris", description: """
    Hannibal is a novel by American author Thomas Harris, published in 1999. It is the third in his series featuring Dr. Hannibal Lecter and the second to feature FBI Special Agent Clarice Starling. The novel takes place seven years after the events of The Silence of the Lambs and deals with the intended revenge of one of Lecter's victims. It was adapted as a film of the same name in 2001, directed by Ridley Scott. Elements of the novel were incorporated into the second season of the NBC television series Hannibal, while the show's third season adapted the plot of the novel.
    """, rating: 4),
            .init(id: 5, name: "Hannibal Rising", imageName: "book_cover_hannibal_rising", author: "Thomas Harris", description: """
                  Hannibal Rising is a novel by American author Thomas Harris, published in 2006. It is a prequel to his three previous books featuring his most famous character, the cannibalistic serial killer Dr. Hannibal Lecter. The novel was released with an initial printing of at least 1.5 million copies[1] and met with a mixed critical response. Audiobook versions have also been released, with Harris reading the text. The novel was adapted (by Harris himself) into a film of the same name in 2007, directed by Peter Webber. Producer Dino De Laurentis implied around the time of the novel's release that he had coerced Harris into writing it under threat of losing control over the Hannibal Lecter character, accounting for the perceived diminished quality from Harris' previous books.
                  """, rating: 4)
        ]
    }
}
