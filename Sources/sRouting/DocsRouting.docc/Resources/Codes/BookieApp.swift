//
//  BookieApp.swift
//  Bookie
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
import sRouting

@sRContext(stacks: "rootStack")
struct SRContext { }

@sRouteObserver(HomeRoute.self)
struct RoutObserver { }

@main
struct BookieApp: App {

    let srcontext = SRContext()
    @State var appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            SRRootView(context: srcontext) {
                NavigationStack(path: srcontext.rootStackPath) {
                    appRouter.rootRoute.screen
                        .routeObserver(RoutObserver.self)
                }
            }
            .environment(MockBookData())
            .environment(appRouter)
        }
    }
}
