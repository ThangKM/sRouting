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
    
    typealias AlertRoute = AppAlertErrors
    typealias ConfirmationDialogRoute = AppConfirmationDialog
    
    case bookDetailScreen(book: BookPersistent.SendableType)

    @MainActor
    var screen: some View {
        switch self {
        case .bookDetailScreen(let book):
            BookDetailScreen(state: .init(book: book))
        }
    }
}
