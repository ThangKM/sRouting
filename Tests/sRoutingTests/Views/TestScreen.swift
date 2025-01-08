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

struct TestRootView: View {
    
    let coordinator: Coordinator
    let router: SRRouter<TestRoute>
    let tests: UnitTestActions<RouterModifier<TestRoute>>?
    
    var body: some View {
        SRRootView(coordinator: coordinator) {
            Text("TestRootView.Screen.Text")
                .onRouting(of: router, tests: tests)
        }
    }
}


struct TestUnitTestActionView: View {
    let coordinator: Coordinator
    let router: SRRouter<TestRoute>
    let tests: UnitTestActions<RouterModifier<TestRoute>>?
    var body: some View {
        SRRootView(coordinator: coordinator) {
            NavigationStackView(path: coordinator.testStackPath) {
                Text("TestNavigationView.Screen.Text")
                    .onRouting(of: router, tests: tests)
            }
        }
    }
}

struct TestViewModifierView<Content: View>: View {
    let coordinator: Coordinator
    let router: SRRouter<TestRoute>
    let content: () -> Content
    
    var body: some View {
        SRRootView(coordinator: coordinator) {
            NavigationStackView(path: coordinator.testStackPath) {
                content()
                    .onRouting(of: router)
            }
        }
    }
}
