//
//  HomeRoute.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

enum HomeRoute: SRRoute {
    
    case bookDetailScreen(book: BookModel)
    
    var path: String { "detailScreen" }
    
    var screen: some View {
        switch self {
        case .bookDetailScreen(let book): BookDetailScreen(book: book)
        }
    }
}

