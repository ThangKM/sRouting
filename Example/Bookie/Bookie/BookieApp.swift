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

@sRouteObserver(AppRoute.self, HomeRoute.self)
struct RouteObserver { }

@main
struct BookieApp: App {

    let appCoordinator = AppCoordinator()
    
    @State var appRouter = AppRouter()
    @State var data = MockBookData()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(coordinator: appCoordinator) {
                NavigationStack(path: appCoordinator.rootStackPath) {
                    appRouter.rootRoute.screen
                        .routeObserver(RouteObserver.self)
                }
            }
            .environment(data)
            .environment(appRouter)
        }
    }
}
