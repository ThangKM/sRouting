//
//  Routes.swift
//
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
@testable import sRouting


struct TimeOutError: Error, CustomStringConvertible {
    var description: String { "time out" }
}

enum TestRoute: SRRoute {
    
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
struct SRContext { }

@sRouteObserver(TestRoute.self)
struct RouteObserver { }
