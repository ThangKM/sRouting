//
//  BookDetailViewModel.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import SwiftUI
import sRouting

@sRouter(HomeRoute.self) @Observable
final class BookDetailViewModel {
    
     var book: BookModel = .empty
    
    func updateBook(_ book: BookModel, isForceUpdate: Bool = false) {
        guard self.book.isEmptyObject || isForceUpdate else { return }
        self.book = book
    }
}
