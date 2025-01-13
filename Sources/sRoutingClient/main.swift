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

enum AppAlerts: SRAlertRoute {
    case lossConnection
    
    var title: LocalizedStringKey {
        switch self {
        case .lossConnection:
            return "Loss Connection"
        }
    }
    
    var actions: some View {
        Button("OK") {
            
        }
    }
    
    var message: some View {
        Text("Please check your connection")
    }
}

enum HomeRoute: SRRoute {

    typealias AlertRoute = AppAlerts
    
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
router.trigger(to: .home, with: .sheet) {
    var trans = Transaction()
    trans.disablesAnimations = true
    return trans
}

router.show(alert: .lossConnection)

@sRouteObserver(HomeRoute.self, SettingRoute.self)
struct RouteObserver { }

@sRouteCoordinator(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
struct AppCoordinator { }

struct TestApp: App {
    
    let coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(coordinator: coordinator) {
                @Bindable var selection = coordinator.tabSelection
                TabView(selection:$selection.selection) {
                    NavigationStack(path: coordinator.homePath) {
                        Text("Home")
                            .routeObserver(RouteObserver.self)
                    }.tag(SRTabItem.homeItem.rawValue)
                    
                    NavigationStack(path: coordinator.settingPath) {
                        Text("Setting")
                            .routeObserver(RouteObserver.self)
                    }.tag(SRTabItem.settingItem.rawValue)
                }
            }
            .onOpenURL { url in
                Task {
                    await coordinator.routing(.resetAll, .select(tabItem: .homeItem),
                                          .push(route: HomeRoute.detail("testing"), into: .home))
                }
            }
        }
    }
}
