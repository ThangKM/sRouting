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

@sRouteObserver(AppRoute.self, HomeRoute.self)
struct RouteObserver { }

@main
struct BookieApp: App {

    let srcontext = SRContext()
    
    @State var appRouter = AppRouter()
    @State var data = MockBookData()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(context: srcontext) {
                NavigationStack(path: srcontext.rootStackPath) {
                    appRouter.rootRoute.screen
                        .routeObserver(RouteObserver.self)
                }
            }
            .environment(data)
            .environment(appRouter)
        }
    }
}
