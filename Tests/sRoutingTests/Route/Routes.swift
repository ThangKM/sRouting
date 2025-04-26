//
//  Routes.swift
//
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
@testable import sRouting

enum TestErrorRoute: SRAlertRoute {
    case timeOut
    var titleKey: LocalizedStringKey { "Error" }
    var actions: some View { Button("Ok") { } }
    var message: some View { Text("Time out!") }
}

enum TestPopover: SRPopoverRoute {
    
    case testPopover
    
    var identifier: String { "Popover identifier" }
    var content: some View {
        VStack {
            Button("OK") {
                
            }
            Button("Cancel") {
            }
        }
    }
}

enum TestDialog: SRConfirmationDialogRoute {
    case confirmOK
    var titleKey: LocalizedStringKey { "Confirm" }
    var identifier: String { "Your question?" }
    var actions: some View {
        VStack {
            Button("OK") {
                
            }
            Button("Cancel") {
            }
        }
    }
    var message: some View { Text(identifier) }
    var titleVisibility: Visibility { .visible }
}

@sRoute
enum TestRoute {
    
    typealias AlertRoute = TestErrorRoute
    typealias ConfirmationDialogRoute = TestDialog
    typealias PopoverRoute = TestPopover

    case home
    case emptyScreen
    case setting
    
    var screen: some View {
        EmptyView()
    }
}

@sRoute
enum AppRoute {
    case main(SRRouter<AppRoute>)
    case login
    
    @MainActor @ViewBuilder
    var screen: some View {
        switch self {
        case .main(let route):
            TestScreen(router: route, tests: nil)
        case .login:
            EmptyView()
        }
        
    }
}

@sRouteCoordinator(tabs:["home", "setting"], stacks: "testStack")
final class Coordinator { }

@sRouteObserver(TestRoute.self)
struct RouteObserver { }
