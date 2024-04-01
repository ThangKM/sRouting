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

@sRouter(HomeRoute.self) @Observable
class HomeViewModel { }


@sRootRouter(stacks: "home", "setting")
struct RootRouter { }


@MainActor
func testing() {
    let rootRouter = RootRouter()
    rootRouter.routing(.push(route: HomeRoute.home, into: .home))
}
