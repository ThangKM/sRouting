//
//  TestModifiers.swift
//
//
//  Created by Thang Kieu on 29/03/2024.
//

import Testing
import ViewInspector
import SwiftUI

@testable import sRouting

@Suite("Test ViewModifiers actions")
@MainActor
struct TestModifiers {
    
    let router = SRRouter(TestRoute.self)
    let coordinator = Coordinator()
    
    @Test
    func testOnDismissAll() async throws {
        var isEnter = false
        let sut = SRRootView(coordinator: coordinator) {
            TestScreen(router: router, tests: .none).onDismissAllChange {
                isEnter.toggle()
            }
        }
        ViewHosting.host(view: sut)
        router.dismissAll()
        try await Task.sleep(for: .milliseconds(50))
        #expect(isEnter)
    }
    
    @Test
    func testOnNavigationStackChange() async throws {
        var pathCount = 0
        let sut = SRRootView(coordinator: coordinator) {
            NavigationStack(path: coordinator.testStackPath) {
                TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                    pathCount = newPaths.count
                }
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for: .milliseconds(50))
        #expect(pathCount == 1)
    }
    
    @Test
    func testOnTabSelectionChange() async throws {
        var tabIndex = 0
        let sut =  SRRootView(coordinator: coordinator) {
            @Bindable var tabSelection = coordinator.tabSelection
            TabView(selection: $tabSelection.selection) {
                TestScreen(router: router, tests: .none)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(0)
                TestScreen(router: router, tests: .none).tabItem {
                    Label("Setting", systemImage: "gear")
                }.tag(1)
            }
            .onTabSelectionChange { value in
                tabIndex = value
            }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 1)
        try await Task.sleep(for: .milliseconds(50))
        #expect(tabIndex == 1)
    }
    
    @Test
    func testOnDoubleTapTabItem() async throws {
        var selection = 1
        let sut =  SRRootView(coordinator: coordinator) {
            @Bindable var tabSelection = coordinator.tabSelection
            TabView(selection: $tabSelection.selection) {
                TestScreen(router: router, tests: .none)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(0)
                TestScreen(router: SRRouter(TestRoute.self), tests: .none).tabItem {
                    Label("Setting", systemImage: "gear")
                }.tag(1)
            }
            .onDoubleTapTabItem { _selection in
                selection = _selection
            }
        }
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(50))
        router.selectTabbar(at: 0)
        try await Task.sleep(for: .milliseconds(100))
        router.selectTabbar(at: 0)
        try await Task.sleep(for: .milliseconds(50))
        #expect(selection == .zero)
    }
    
    @Test
    func testNoneDoubleTapTabItem() async throws {
        let sut =  SRRootView(coordinator: coordinator) {
            @Bindable var tabSelection = coordinator.tabSelection
            TabView(selection: $tabSelection.selection) {
                TestScreen(router: router, tests: .none)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(0)
            }
            .onDoubleTapTabItem { selection in
                Issue.record()
            }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 0)
        try await Task.sleep(for: .milliseconds(500))
        router.selectTabbar(at: 0)
    }
}
