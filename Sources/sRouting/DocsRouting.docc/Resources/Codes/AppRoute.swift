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
    
    case startScreen
    case homeScreen
    
    @ViewBuilder @MainActor
    var screen: some View {
        switch self {
        case .startScreen:
            StartScreen()
                .transition(.scale(scale: 0.1).combined(with: .opacity))
        case .homeScreen:
            MainScreen()
                .transition(.opacity)
        }
    }
}

struct MainScreen: View {
    @Environment(AppCoordinator.self) var coordinator
    var body: some View {
        NavigationStack(path: coordinator.rootStackPath) {
            HomeScreen()
                .routeObserver(RouteObserver.self)
        }
    }
}
