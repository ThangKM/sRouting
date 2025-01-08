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
        let sut = TestUnitTestActionView(coordinator: coordinator, router: router, tests: .init(didChangeTransition: { view in
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
        let sut = TestUnitTestActionView(coordinator: coordinator, router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveAlert
        }))
        
        ViewHosting.host(view: sut)
        router.show(error: TimeOutError())
        try await Task.sleep(for: .milliseconds(10))
        #expect(isActive)
    }
    
    @Test
    func testDismissAll() async throws {
        var isActive = true
        let sut = TestUnitTestActionView(coordinator: coordinator, router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveAlert && view.isActiveSheet && view.isActivePresent && view.isActiveActionSheet
        }))
        
        ViewHosting.host(view: sut)
        router.dismissAll()
        try await Task.sleep(for: .milliseconds(10))
        #expect(!isActive)
    }
    
    @Test
    func testPush() async throws {
        var pathCount = 0
        let sut =  TestViewModifierView(coordinator: coordinator, router: router) {
            Text("Test").onNaviStackChange { newPaths in
                pathCount = newPaths.count
            }
        }
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for: .milliseconds(10))
        #expect(pathCount == 1)
    }
    
    @Test
    func testPop() async throws {
        var pathCount = 1
        let sut = TestViewModifierView(coordinator: coordinator, router: router) {
            Text("Test").onNaviStackChange { newPaths in
                pathCount = newPaths.count
            }
        }
        ViewHosting.host(view: sut)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.pop()
        try await Task.sleep(for: .milliseconds(10))
        #expect(pathCount == .zero)
    }
    
    @Test
    func testPopToRoot() async throws {
        var pathCount = 1
        let sut = TestViewModifierView(coordinator: coordinator, router: router) {
            Text("Test").onNaviStackChange { newPaths in
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
        
        let sut = TestViewModifierView(coordinator: coordinator, router: router) {
            Text("Test").onNaviStackChange { newPaths in
                paths = newPaths
                print(paths)
            }
        }
        ViewHosting.host(view: sut)
        try await Task.sleep(for:.milliseconds(50))
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
                                                          
    #if os(iOS) || os(tvOS)
    @Test
    func testActiveActionSheet() async throws {
        var isActive = false
        let sut =
        TestUnitTestActionView(coordinator: coordinator, router: router, tests:.init(didChangeTransition: { view in
            isActive = view.isActiveActionSheet
        }))
        ViewHosting.host(view: sut)
        router.show(actionSheet: {
            .init(title: Text("test"))
        })
        try await Task.sleep(for: .milliseconds(10))
        #expect(isActive)
    }
    
    @Test
    func testActivePresent() async throws {
        var isActive = false
        let sut = TestUnitTestActionView(coordinator: coordinator, router: router, tests:.init(didChangeTransition: { view in
            isActive = view.isActivePresent
        }))
        
        ViewHosting.host(view: sut)
        router.trigger(to: .home, with: .present)
        try await Task.sleep(for: .milliseconds(10))
        #expect(isActive)
    }
    
    #endif
}
