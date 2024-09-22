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
    case deatail(String)
    
    var path: String {
        return "Home"
    }
    
    var screen: some View {
        Text("hello word")
    }
}

enum SettingRoute: SRRoute {
    case setting
    
    var path: String { "setting" }
    
    var screen: some View { Text("Setting") }
}

@sRouter(HomeRoute.self) @Observable
final class HomeRouter { }
 
@sRouteObserve(HomeRoute.self, SettingRoute.self)
struct ObserveView<Content>: View where Content: View { }

@sRContext(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
struct SRContext { }

@MainActor
func routingDeeplink() {
    let context = SRContext()
    Task {
        await context.routing(.resetAll, .select(tabItem: .homeItem),
                              .push(route: HomeRoute.deatail("detail"), into: .home))
    }
}
