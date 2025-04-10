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

enum AppPopover: SRPopoverRoute {
    
    case testPopover
    
    var identifier: String { "indentifier" }
    
    var content: some View {
        Text("Hello, World!")
    }
}

enum AppConfirmationDialog: SRConfirmationDialogRoute {
    
    case testConfirmation
    
    var titleKey: LocalizedStringKey {
        "This is Title"
    }
    
    var identifier: String {
        "This is Message"
    }
    
    var message: some View {
        Text(identifier)
    }
    
    var actions: some View {
        Button("Yes") { }
        Button("No", role: .destructive) { }
    }
        
    var titleVisibility: Visibility {
        .visible
    }
}

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
    typealias ConfirmationDialogRoute = AppConfirmationDialog
    typealias PopoverRoute = AppPopover
    
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
router.show(dialog: .testConfirmation)
router.show(popover: .testPopover)

@sRouteObserver(HomeRoute.self, SettingRoute.self)
struct RouteObserver: ViewModifier { }

@sRouteCoordinator(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
final class AppCoordinator { }

@sRouteCoordinator(stacks: "subcoordinator")
final class OtherCoordinator { }

struct TestApp: App {
    
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var context = SRContext()
    @StateObject private var emitter = SRCoordinatorEmitter()
    
    init() {
        let coordinator = AppCoordinator()
        self._coordinator = .init(wrappedValue: coordinator)
        self._emitter = .init(wrappedValue: coordinator.emitter)
    }
    
    var body: some Scene {
        WindowGroup {
            SRRootView(context: context, coordinator: coordinator) {
                TabView(selection: $emitter.tabSelection) {
                    NavigationStackView(path: coordinator.homePath) {
                        Text("Home")
                            .routeObserver(RouteObserver.self)
                    }.tag(AppCoordinator.SRTabItem.homeItem.rawValue)
                    
                    NavigationStackView(path: coordinator.settingPath) {
                        Text("Setting")
                            .routeObserver(RouteObserver.self)
                    }.tag(AppCoordinator.SRTabItem.settingItem.rawValue)
                }
            }
            .onOpenURL { url in
                Task {
                    await context.routing(.resetAll,
                                          .selectTabView(AppCoordinator.SRTabItem.homeItem),
                                          .push(route: HomeRoute.detail("testing")))
                }
            }
        }
    }
}
