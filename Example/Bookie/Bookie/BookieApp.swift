//
//  BookieApp.swift
//  Bookie
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
import sRouting

@Observable
@sRouteCoordinator(stacks: "rootStack")
final class AppCoordinator { }

@sRouteObserver(AppRoute.self, HomeRoute.self)
struct RouteObserver { }

@main
struct BookieApp: App {

    @State private var appCoordinator = AppCoordinator()
    @State private var data = MockBookData()
    
    @AppStorage("didTutorial")
    private var didShowTutorial: Bool = false
    
    var body: some Scene {
        WindowGroup {
            SRRootView(coordinator: appCoordinator) {
                NavigationStack(path: appCoordinator.rootStackPath) {
                    rootScreen
                        .routeObserver(RouteObserver.self)
                }
            }
            .environment(data)
        }
    }
}

extension BookieApp {
    
    @ViewBuilder
    private var rootScreen: some View {
        if didShowTutorial {
            AppRoute.homeScreen.screen
        } else {
            AppRoute.startScreen.screen
        }
    }
}
