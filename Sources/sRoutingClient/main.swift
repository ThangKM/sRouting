//
//  main.swift
//
//
//  Created by Thang Kieu on 18/03/2024.
//

import Foundation
import sRouting
import SwiftUI
import Observation

enum HomeRoute: SRRoute {

    case home
    case detail(String)
    
    var path: String {
        return "Home"
    }
    
    var screen: some View {
        Text("Hello World")
    }
}

enum SettingRoute: SRRoute {
    case setting
    
    var path: String { "setting" }
    
    var screen: some View { Text("Setting") }
}

let router = SRRouter(HomeRoute.self)
router.trigger(to: .home, with: .present) {
    var trans = Transaction()
    trans.disablesAnimations = true
    return trans
}

@sRouteObserver(HomeRoute.self, SettingRoute.self)
struct RouteObserver { }

@sRContext(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
struct SRContext { }

struct TestApp: App {
    
    let context = SRContext()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(context: context) {
                @Bindable var selection = context.tabSelection
                TabView(selection:$selection.selection) {
                    NavigationStack(path: context.homePath) {
                        Text("Home")
                            .routeObserver(RouteObserver.self)
                    }.tag(SRTabItem.homeItem.rawValue)
                    
                    NavigationStack(path: context.settingPath) {
                        Text("Setting")
                            .routeObserver(RouteObserver.self)
                    }.tag(SRTabItem.settingItem.rawValue)
                }
            }
            .onOpenURL { url in
                Task {
                    await context.routing(.resetAll, .select(tabItem: .homeItem),
                                          .push(route: HomeRoute.detail("testing"), into: .home))
                }
            }
        }
    }
}
