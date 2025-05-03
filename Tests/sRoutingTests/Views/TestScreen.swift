//
//  TestScreen.swift
//  
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI
import ViewInspector
import Testing

@testable import sRouting

struct TestScreen<R>: View where R: SRRoute {
    
    let router: SRRouter<R>
    let tests: UnitTestActions<RouterModifier<R>>?
    
    var body: some View {
        Text("TestScreen.Screen.Text")
            .onRouting(of: router, tests: tests)
    }
}


struct DialogScreen: View {
    
    let router: SRRouter<TestRoute>
    let tests: UnitTestActions<DialogRouterModifier<TestRoute>>?
    
    var body: some View {
        Text("DialogScreen.Text")
            .onDialogRouting(of: router, for: .confirmOK, tests: tests)
    }
}


struct PopoverScreen: View {
    
    let router: SRRouter<TestRoute>
    let tests: UnitTestActions<OnPopoverOfRouter<TestRoute>>?
    
    var body: some View {
        Text("DialogScreen.Text")
            .onPopoverRouting(of: router, for: .testPopover, tests: tests)
    }
}

struct TestCoordinatorView: View {
    
    let context: SRContext
    let coordinator: Coordinator
    let router: SRRouter<TestRoute>
    
    var body: some View {
        SRRootView(context: context, coordinator: coordinator) {
            TestScreen(router: router, tests: nil)
        }
        .onRoutingCoordinator(TestRoute.self, context: context)
    }
}
