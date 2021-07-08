//
//  BookDetailViewModel.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import Foundation
import sRouting

@MainActor
final class BookDetailViewModel: Router<HomeRoute> {
    
    @Published var book: BookModel = .empty
    
    func updateBook(_ book: BookModel, isForceUpdate: Bool = false) {
        guard self.book.isEmptyObject || isForceUpdate else { return }
        self.book = book
    }
}
