//
//  HomeViewModel.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import Foundation
import sRouting
import Combine

@MainActor
class HomeViewModel: Router<HomeRoute> {
    
    @Published var textInSearch: String = "" {
        didSet { findBooks(withText: textInSearch) }
    }
    
    @Published
    private(set) var books: [BookModel] = []
    
    private var allBooks: [BookModel] = [] {
        didSet { findBooks(withText: textInSearch) }
    }
    
    func updateAllBooks(books: [BookModel],
                        isForceUpdate isForce: Bool = false) {
        guard allBooks.isEmpty || isForce else { return }
        allBooks = books
    }
    
    func pushDetail(of book: BookModel) {
        trigger(to: .bookDetailScreen(book: book), with: .allCases.randomElement() ?? .push)
    }
}

extension HomeViewModel {
    
    private func findBooks(withText text: String) {
        guard !text.isEmpty else { books = allBooks; return }
        books =  allBooks.filter { $0.name.contains(text) || $0.author.contains(text) }
    }
}
