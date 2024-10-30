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
    
    let router = TestRouter()
    let waiter = Waiter()
    let context = SRContext()
    
    @Test
    func testActiveSheet() async throws {
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            #expect(view.isActiveSheet)
            waiter.finish()
        }))
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .sheet)
        try await waiter.await(for: 0.2)
    }
    
    @Test
    func testActiveAlert() async throws {
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            #expect(view.isActiveAlert)
            waiter.finish()
        }))
        
        ViewHosting.host(view: sut)
        router.show(error: NSError(domain: "unittest.navigator", code: -1, userInfo: [:]), and: nil)
        try await waiter.await(for: 0.2)
    }
    
    @Test
    func testDismissAll() async throws {
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            #expect(!view.isActiveAlert)
            #expect(!view.isActiveSheet)
            #expect(!view.isActivePresent)
            #expect(!view.isActiveActionSheet)
            waiter.finish()
        }))
        
        ViewHosting.host(view: sut)
        
        router.dismissAll()
        try await waiter.await(for: 0.2)
    }
    
    @Test
    func testPush() async throws {
        let sut = NavigationStack(path: context.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                #expect(newPaths.count == 1)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        try await waiter.await(for: 0.2)
    }
    
    @Test
    func testPop() async throws {
        let sut = NavigationStack(path: context.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                guard newPaths.count == .zero else { return }
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.pop()
        try await waiter.await(for: 0.2)
    }
    
    @Test
    func testPopToRoot() async throws {
        let sut = NavigationStack(path: context.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                guard newPaths.count == .zero else { return }
                waiter.finish()
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
        try await waiter.await(for: 0.2)
    }
    
    @Test
    func testPopToTarget() async throws {
        let sut = NavigationStack(path: context.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                guard let path = newPaths.first, newPaths.count == 1 else { return }
                #expect(path.contains("home"))
                waiter.finish()
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
        try await waiter.await(for: 0.2)
    }
                                                          
    #if os(iOS) || os(tvOS)
    @Test
    func testActiveActionSheet() async throws {
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            #expect(view.isActiveActionSheet)
            waiter.finish()
        }))
        
        ViewHosting.host(view: sut)
        router.show(actionSheet: .init(title: Text("test")))
        try await waiter.await(for: 0.2)
    }
    
    @Test
    func testActivePresent() async throws {
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            #expect(view.isActivePresent)
            waiter.finish()
        }))
        
        ViewHosting.host(view: sut)
        router.trigger(to: .home, with: .present)
        try await waiter.await(for: 0.2)
    }
    
    #endif
}
