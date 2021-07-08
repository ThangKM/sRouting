//
//  BookieApp.swift
//  Bookie
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
import sRouting

@main
struct BookieApp: App {

    @StateObject
    private var rootRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView(rootRouter: rootRouter) {
                NavigationView {
                    rootRouter.rootRoute.screen
                }
            }
            .navigationViewStyle(.stack)
            .environmentObject(MockBookData())
        }
    }
}
