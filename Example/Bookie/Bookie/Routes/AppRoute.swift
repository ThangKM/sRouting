//
//  AppRoute.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting


enum AppRoute: SRRoute {
    
    case startScreen(store: StartScreen.StartStore)
    case homeScreen
    
    var path: String {
        switch self {
        case .startScreen: return "startScreen"
        case .homeScreen: return "homeScreen"
        }
    }
    
    var screen: some View {
        switch self {
        case .startScreen(let store): StartScreen(store: store)
        case .homeScreen: HomeScreen()
        }
    }
}

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
        case .failedSyncBooks: return "Failed Sync Books!"
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
