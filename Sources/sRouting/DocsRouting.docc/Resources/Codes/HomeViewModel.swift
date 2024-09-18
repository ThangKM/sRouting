//
//  HomeViewModel.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import Foundation
import sRouting
import Combine

@Observable
final class HomeViewModel {
    
    var textInSearch: String = "" {
        didSet { findBooks(withText: textInSearch) }
    }
    
    private(set) var books: [BookModel] = []
    
    private var allBooks: [BookModel] = [] {
        didSet { findBooks(withText: textInSearch) }
    }
    
    func updateAllBooks(books: [BookModel],
                        isForceUpdate isForce: Bool = false) {
        guard allBooks.isEmpty || isForce else { return }
        allBooks = books
    }
    
    @MainActor
    func pushDetail(of book: BookModel) {
        trigger(to: .bookDetailScreen(book: book), with: .allCases.randomElement() ?? .push)
    }
}

extension HomeViewModel {
    
    private func findBooks(withText text: String) {
        guard !text.isEmpty else { books = allBooks; return }
        books =  allBooks.filter { $0.name.lowercased().contains(text.lowercased()) || $0.author.lowercased().contains(text.lowercased()) }
    }
}
