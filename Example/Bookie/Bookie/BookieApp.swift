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
    @State private var bookService = MockBookService()

    var body: some Scene {
        WindowGroup {
            SRRootView(coordinator: appCoordinator) {
                NavigationStack(path: appCoordinator.rootStackPath) {
                    RootScreen()
                        .routeObserver(RouteObserver.self)
                }
            }
            .environment(bookService)
        }
    }
}

extension BookieApp {
    
    private struct RootScreen: View {
        
        @AppStorage("didTutorial")
        private var didShowTutorial: Bool = false
        
        var body: some View {
            if didShowTutorial {
                AppRoute.homeScreen.screen
            } else {
                AppRoute.startScreen.screen
            }
        }
    }
}
