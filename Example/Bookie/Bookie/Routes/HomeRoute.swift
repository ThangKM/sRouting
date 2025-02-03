//
//  HomeRoute.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

enum HomeRoute: SRRoute {
    
    typealias AlertRoute = AppAlertErrors
    typealias ConfirmationDialogRoute = AppConfirmationDialog
    
    case bookDetailScreen(book: BookPersistent.SendableType)
    
    var path: String { "detailScreen" }
    
    var screen: some View {
        switch self {
        case .bookDetailScreen(let book):
            BookDetailScreen(state: .init(book: book))
        }
    }
}
