//
//  BookieApp.swift
//  Bookie
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
import sRouting


@sRouteCoordinator(stacks: "rootStack") @Observable
final class AppCoordinator { }

@sRouteObserver(HomeRoute.self)
struct RouteObserver { }

@main
struct BookieApp: App {

    @State private var appCoordinator = AppCoordinator()
    @State private var context = SRContext()
    @State private var mockData = MockBookData()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(context: context, coordinator: appCoordinator) {
                SRSwitchView(startingWith: AppRoute.startScreen)
            }
            .environment(mockData)
        }
    }
}
