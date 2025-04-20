//
//  AppRoute.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

@sRoute
enum AppRoute {
    
    case startScreen(store: StartScreen.StartStore)
    case homeScreen
    
    @ViewBuilder @MainActor
    var screen: some View {
        switch self {
        case .startScreen(let store):
            StartScreen(store: store)
        case .homeScreen:
            HomeScreen()
        }
    }
}

//MARK: - AppAlertErrors
enum AppAlertErrors: SRAlertRoute, CustomNSError, CustomStringConvertible  {
    
    case failedSyncBooks
    
    static var errorDomain: String { "com.bookie.app" }
    
    var errorCode: Int  {
        switch self {
        case .failedSyncBooks: return -1
        }
    }
    
    var description: String {
        switch self {
        case .failedSyncBooks: return "Failed to generate Books!"
        }
    }

    var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: description]
    }
    
    var titleKey: LocalizedStringKey {
        ""
    }
    
    var actions: some View {
        Button("OK") {
            
        }
    }
    
    var message: some View {
        Text(description)
    }
    
}

struct AppAlertsRoute: SRRoute {

    typealias AlertRoute = AppAlertErrors
    
    var path: String {
        assertionFailure()
        return "AppAlertsRoute.Unsuppported"
    }
    
    var screen: some View {
        assertionFailure()
        return EmptyView()
    }
    
}

//MARK: - Confirmation Dialog

enum AppConfirmationDialog: SRConfirmationDialogRoute {

    case delete(confirmedAction: @Sendable @MainActor () -> Void)
    
    var titleKey: LocalizedStringKey {
        switch self {
        case .delete: return "Delete"
        }
    }
    
    var identifier: String {
        switch self {
        case .delete(_):
            "Are you sure you want to delete this item?"
        }
    }
    var titleVisibility: Visibility {
        switch self {
        case .delete: return .visible
        }
    }
    
    var actions: some View {
        switch self {
        case .delete(let action):
            Button("YES", role: .destructive, action:  action)
        }
    }
    
    var message: some View {
        switch self {
        case .delete:
            Text(identifier)
                .abeeFont(size: 13, style: .regular)
        }
    }
}
