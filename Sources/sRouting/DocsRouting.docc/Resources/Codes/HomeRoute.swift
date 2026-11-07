//
//  HomeRoute.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

@sRoute
enum HomeRoute {
    
    case bookDetailScreen(book: BookModel)
    
    @ViewBuilder @MainActor
    var screen: some View {
        switch self {
        case .bookDetailScreen(let book): BookDetailScreen(book: book)
        }
    }
}

