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

    @State var appCoordinator = AppCoordinator()
    @State var context = SRContext()
    @State var appRouter = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(context: context, coordinator: appCoordinator) {
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
