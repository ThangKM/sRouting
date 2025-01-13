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
    var title: LocalizedStringKey { "Error" }
    var actions: some View { Text("Ok") }
    var message: some View { Text("Time out!") }
}

enum TestRoute: SRRoute {
    
    typealias AlertRoute = TestErrorRoute
    
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
struct Coordinator { }

@sRouteObserver(TestRoute.self)
struct RouteObserver: ViewModifier { }

