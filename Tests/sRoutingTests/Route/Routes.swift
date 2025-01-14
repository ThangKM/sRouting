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
    var actions: some View { Text("Ok") }
    var message: some View { Text("Time out!") }
}

#if os(iOS)
enum TestDialog: SRConfirmationDialogRoute {
    case confirmOK
    var titleKey: LocalizedStringKey { "Confirm" }
    var actions: some View {
        VStack {
            Button("OK") {
                
            }
            Button("Cancel") {
            }
        }
    }
    var message: some View { Text("Your question?") }
    var titleVisibility: Visibility { .visible }
}
#endif

enum TestRoute: SRRoute {
    
    typealias AlertRoute = TestErrorRoute
    #if os(iOS)
    typealias ConfirmationDialogRoute = TestDialog
    #endif
    
    var path: String {
        switch self {
        case .emptyScreen: "empty screen"
        case .home: "home screen"
        case .setting: "setting screen"
        }
    }
    
    case home
    case emptyScreen
    case setting
    
    var screen: some View {
        EmptyView()
    }
}

@sRouteCoordinator(stacks: "testStack")
final class Coordinator { }

@sRouteObserver(TestRoute.self)
struct RouteObserver: ViewModifier { }

