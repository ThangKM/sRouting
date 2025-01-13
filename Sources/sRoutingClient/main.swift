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
router.trigger(to: .home, with: .present) {
    var trans = Transaction()
    trans.disablesAnimations = true
    return trans
}

@sRouteObserver(HomeRoute.self, SettingRoute.self)
struct RouteObserver: ViewModifier { }

@sRouteCoordinator(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
struct AppCoordinator { }

struct TestApp: App {
    
    let appCoordinator: AppCoordinator
    @StateObject var tabselection: SRTabbarSelection
    
    init() {
        let coordinator = AppCoordinator()
        appCoordinator = coordinator
        _tabselection = .init(wrappedValue: coordinator.tabSelection)
    }
    
    var body: some Scene {
        WindowGroup {
            SRRootView(coordinator: appCoordinator) {
                TabView(selection:$tabselection.selection) {
                    NavigationStackView(path: appCoordinator.homePath) {
                        Text("Home")
                            .routeObserver(RouteObserver.self)
                    }.tag(SRTabItem.homeItem.rawValue)
                    
                    NavigationStackView(path: appCoordinator.settingPath) {
                        Text("Setting")
                            .routeObserver(RouteObserver.self)
                    }.tag(SRTabItem.settingItem.rawValue)
                }
            }
            .onOpenURL { url in
                Task {
                    await appCoordinator.routing(.resetAll, .select(tabItem: .homeItem),
                                          .push(route: HomeRoute.detail("testing"), into: .home))
                }
            }
        }
    }
}
