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

@sRoute
enum HomeRoute {

    typealias AlertRoute = AppAlerts
    typealias ConfirmationDialogRoute = AppConfirmationDialog
    typealias PopoverRoute = AppPopover
    
    case home
    case detail(String)
    
    var screen: some View {
        Text("Hello World")
    }
}

@sRoute
enum SettingRoute {
    case setting
    
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
struct RouteObserver { }

@sRouteCoordinator(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
@Observable
final class AppCoordinator { }

@sRouteCoordinator(stacks: "subcoordinator")
final class OtherCoordinator { }

@sRoute
enum AppRoute {
    
    case startScreen
    case homeScreen
    
    @ViewBuilder @MainActor
    var screen: some View {
        switch self {
        case .startScreen:
            EmptyView()
                .transition(.scale(scale: 0.1).combined(with: .opacity))
        case .homeScreen:
            MainScreen()
                .transition(.opacity)
        }
    }
}

struct MainScreen: View {
    @Environment(AppCoordinator.self) var coordinator
    var body: some View {
        NavigationStack(path: coordinator.homePath) {
            EmptyView()
                .routeObserver(RouteObserver.self)
        }
    }
}

struct BookieApp: App {

    @State private var appCoordinator = AppCoordinator()
    @State private var context = SRContext()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(context: context, coordinator: appCoordinator) {
                SRSwitchView(startingWith: AppRoute.startScreen)
            }
            .environment(appCoordinator)
        }
    }
}

struct BookieApp_OtherSetup: App {

    @State private var appCoordinator = AppCoordinator()
    @State private var context = SRContext()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(context: context, coordinator: appCoordinator) {
                SRSwitchRouteView(startingWith: AppRoute.startScreen) { route in
                    NavigationStack(path: appCoordinator.homePath) {
                        route.screen
                            .routeObserver(RouteObserver.self)
                    }
                }
            }
        }
    }
}
