//
//  BookieApp.swift
//  Bookie
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
import sRouting
import SwiftData

@sRouteCoordinator(stacks: "rootStack")
@Observable
final class AppCoordinator { }

@sRouteObserver(AppRoute.self, HomeRoute.self)
struct RouteObserver { }

@main
struct BookieApp: App {

    @State private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            SRRootView(coordinator: appCoordinator) {
                NavigationStack(path: appCoordinator.rootStackPath) {
                    RootScreen()
                        .routeObserver(RouteObserver.self)
                }
            }
            .modelContainer(DatabaseProvider.shared.container)
        }
    }
}
