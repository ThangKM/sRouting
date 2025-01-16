//
//  BookieApp.swift
//  Bookie
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
import sRouting

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
        
        @State private var startHome = false
        
        private var showHomeAcion: AsyncActionPut<Bool> {
            .init { @MainActor value in
                withAnimation {
                    startHome = value
                }
            }
        }
        
        var body: some View {
            if startHome {
                AppRoute.homeScreen.screen
                    .transition(.asymmetric(insertion: .scale(scale: 3), removal: .scale(scale: 0.2)).combined(with: .opacity))
                    .animation(.easeInOut(duration: 1), value: 1)
            } else {
                AppRoute.startScreen(startAction: showHomeAcion)
                .screen
                    .transition(.asymmetric(insertion: .scale(scale: 0.2), removal: .scale(scale: 0.2)).combined(with: .opacity))
                    .animation(.easeInOut(duration: 1), value: 1)
            }
        }
    }
}
