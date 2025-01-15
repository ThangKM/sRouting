//
//  RouterModifierTests.swift
//
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI
import ViewInspector
import Testing
@testable import sRouting

@Suite("Test RouterModifer")
@MainActor
struct RouterModifierTests {
    
    let router = SRRouter(TestRoute.self)
    let coordinator = Coordinator()
    
    @Test
    func testActiveSheet() async throws {
        var isActive = false
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveSheet
        }))
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .sheet)
        try await Task.sleep(for: .milliseconds(10))
        #expect(isActive)
    }
    
    @Test
    func testActiveAlert() async throws {
        var isActive = false
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveAlert
        }))
        
        ViewHosting.host(view: sut)
        router.show(alert: .timeOut)
        try await Task.sleep(for: .milliseconds(10))
        #expect(isActive)
    }
    
    @Test
    func testDismissAll() async throws {
        var isActive = true
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveAlert && view.isActiveSheet && view.isActivePresent && view.isActiveDialog
        }))
        
        ViewHosting.host(view: sut)
        router.dismissAll()
        try await Task.sleep(for: .milliseconds(10))
        #expect(!isActive)
    }
    
    @Test
    func testDismissCoordinator() async throws {
        var isEnter = false

        let sut = SRRootView(coordinator: coordinator) {
            TestScreen(router: router, tests: nil)
                .onChange(of: coordinator.dismissAllEmitter.dismissCoordinatorSignal) { oldValue, newValue in
                    isEnter = true
                }
        }
        
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.dismissCoordinator()
        try await Task.sleep(for: .milliseconds(10))
        #expect(isEnter)
    }
    
    @Test
    func testPush() async throws {
        var pathCount = 0
        let sut = NavigationStack(path: coordinator.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                pathCount = newPaths.count
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for: .milliseconds(10))
        #expect(pathCount == 1)
    }
    
    @Test
    func testPop() async throws {
        var pathCount = 1
        let sut = NavigationStack(path: coordinator.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                pathCount = newPaths.count
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.pop()
        try await Task.sleep(for: .milliseconds(10))
        #expect(pathCount == .zero)
    }
    
    @Test
    func testPopToRoot() async throws {
        var pathCount = 1
        let sut = NavigationStack(path: coordinator.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                pathCount = newPaths.count
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .home, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .setting, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.popToRoot()
        try await Task.sleep(for: .milliseconds(10))
        #expect(pathCount == .zero)
    }
    
    @Test
    func testPopToTarget() async throws {
        var paths = [String]()
        
        let sut = NavigationStack(path: coordinator.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                paths = newPaths
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .home, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .setting, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.pop(to: TestRoute.home)
        let path = try #require(paths.first)
        try await Task.sleep(for: .milliseconds(10))
        #expect(paths.count == 1)
        #expect(path.contains("home"))
    }
    
    @Test
    func testOnDoubleTap() async throws {
        
        var selection = -1
        let tabManager = SRTabbarSelection()
        let sut = Text("")
                    .onDoubleTapTabItem { value in
                        selection = value
                    }
                    .environment(tabManager)
        ViewHosting.host(view: sut)
        try await Task.sleep(for:.milliseconds(50))
        tabManager.select(tag: 0)
        try await Task.sleep(for:.milliseconds(100))
        tabManager.select(tag: 0)
        try await Task.sleep(for:.milliseconds(50))
        #expect(selection == .zero)
    }
    
    @Test
    func testActiveActionSheet() async throws {
        var isActive = false
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveDialog
        }))
        
        ViewHosting.host(view: sut)
        router.show(dialog: .confirmOK)
        try await Task.sleep(for: .milliseconds(10))
        #expect(isActive)
    }
                                                       
    #if os(iOS) || os(tvOS)
    @Test
    func testActivePresent() async throws {
        var isActive = false
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActivePresent
        }))
        
        ViewHosting.host(view: sut)
        router.trigger(to: .home, with: .present)
        try await Task.sleep(for: .milliseconds(10))
        #expect(isActive)
    }
    
    #endif
}
