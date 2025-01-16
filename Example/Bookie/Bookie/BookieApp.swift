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
                    .transition(.asymmetric(insertion: .scale(scale: 0.2), removal: .scale(scale: 0.2)).combined(with: .opacity))
                    .animation(.easeInOut(duration: 1), value: 1)
            } else {
                AppRoute.startScreen(startAction: .init({@MainActor didStart in
                    withAnimation {
                        didShowTutorial = didStart
                    }
                }))
                .screen
                    .transition(.asymmetric(insertion: .scale(scale: 0.2), removal: .scale(scale: 0.2)).combined(with: .opacity))
                    .animation(.easeInOut(duration: 1), value: 1)
            }
        }
    }
}
