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

@sRouteCoordinator(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
struct AppCoordinator { }

struct TestApp: App {
    
    let appCoordinator: AppCoordinator
    @StateObject var tabselection: SRTabbarSelection
    @StateObject var homePath: SRNavigationPath
    @StateObject var settingPath: SRNavigationPath
    
    init() {
        let coordinator = AppCoordinator()
        appCoordinator = coordinator
        _tabselection = .init(wrappedValue: coordinator.tabSelection)
        _homePath = .init(wrappedValue: coordinator.homePath)
        _settingPath = .init(wrappedValue: coordinator.settingPath)
    }
    
    var body: some Scene {
        WindowGroup {
            SRRootView(coordinator: appCoordinator) {
                TabView(selection:$tabselection.selection) {
                    NavigationStack(manager: homePath, path: $homePath.navPath) {
                        Text("Home")
                            .routeObserver(RouteObserver.self)
                    }.tag(SRTabItem.homeItem.rawValue)
                    
                    NavigationStack(manager: settingPath, path: $settingPath.navPath) {
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
