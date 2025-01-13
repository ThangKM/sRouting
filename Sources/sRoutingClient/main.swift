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

#if canImport(UIKit)
enum AppConfirmationDialog: SRConfirmationDialogRoute {
    case testConfirmation
    
    var titleKey: LocalizedStringKey {
        "This is Title"
    }
    
    var message: some View {
        Text("This is Message")
    }
    
    var actions: some View {
        Button("Yes") { }
        Button("No", role: .destructive) { }
    }
        
    var titleVisibility: Visibility {
        .visible
    }
}
#endif

enum AppAlerts: SRAlertRoute {
    
    case lossConnection
    
    var titleKey: LocalizedStringKey {
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
    #if canImport(UIKit)
    typealias ConfirmationDialogRoute = AppConfirmationDialog
    #endif
    
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

#if canImport(UIKit)
router.show(dialog: .testConfirmation)
#endif

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
