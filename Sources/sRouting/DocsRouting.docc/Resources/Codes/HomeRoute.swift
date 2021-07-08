//
//  HomeRoute.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

enum HomeRoute: Route {
    
    case bookDetailScreen(book: BookModel)
    
    var screen: some View {
        switch self {
        case .bookDetailScreen(let book): BookDetailScreen(book: book)
        }
    }
}

