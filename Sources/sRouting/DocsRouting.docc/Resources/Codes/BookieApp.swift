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

@sRouteObserve(HomeRoute.self)
struct ObserveView { }

@main
struct BookieApp: App {

    let srcontext = SRContext()
    @State var appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            SRRootView(context: srcontext) {
                SRNavigationStack(path: srcontext.rootStackPath, observeView: ObserveView.self) {
                    appRouter.rootRoute.screen
                }
            }
            .environment(MockBookData())
            .environment(appRouter)
        }
    }
}
