//
//  BookieApp.swift
//  Bookie
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
import sRouting

@sRouteCoordinator(stacks: "rootStack")
struct AppCoordinator { }

@sRouteObserver(HomeRoute.self)
struct RoutObserver { }

@main
struct BookieApp: App {

    let appCoordinator = AppCoordinator()
    @State var appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            SRRootView(coordinator: appCoordinator) {
                NavigationStack(path: appCoordinator.rootStackPath) {
                    appRouter.rootRoute.screen
                        .routeObserver(RoutObserver.self)
                }
            }
            .environment(MockBookData())
            .environment(appRouter)
        }
    }
}
