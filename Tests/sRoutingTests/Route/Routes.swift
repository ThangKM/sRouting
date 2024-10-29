//
//  Routes.swift
//
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
@testable import sRouting

enum EmptyRoute: SRRoute {
    
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

enum HomeRoute: SRRoute {
    
    var path: String { "home screen" }
    
    
    case home
    
    var screen: some View {
        EmptyView()
    }
}

@sRouter(EmptyRoute.self) @Observable
class TestRouter { }

@sRContext(stacks: "home")
struct SRContext { }

@sRouteObserver(EmptyRoute.self, HomeRoute.self)
struct RouteObserver { }
