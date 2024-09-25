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
    
    let router = TestRouter()
    let waiter = Waiter()
    let context = SRContext()
    
    @Test
    func testOnDismissAll() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onDismissAllChange {
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.dismissAll()
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testOnNavigationStackChange() async throws {
        let sut = SRRootView(context: context) {
            SRNavigationStack(path: .init(), observeView: ObserveView.self) {
                TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                    #expect(oldPaths.isEmpty)
                    #expect(newPaths.count == 1)
                    waiter.finish()
                }
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testOnTabSelectionChange() async throws {
        let sut =  SRRootView(context: context) {
            SRTabbarView {
                TestScreen(router: router, tests: .none)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(0)
                    .onTabSelectionChange { value in
                        #expect(value == 1)
                        waiter.finish()
                    }
                
                TestScreen(router: router, tests: .none).tabItem {
                    Label("Setting", systemImage: "gear")
                }.tag(1)
            }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 1)
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testOnDoubleTapTabItemChange() async throws {
        let sut =  SRRootView(context: context) {
            SRTabbarView {
                TestScreen(router: router, tests: .none)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(0)
            }
            .onDoubleTapTabItem { selection in
                #expect(selection == .zero)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 0)
        try await Task.sleep(for: .milliseconds(100))
        router.selectTabbar(at: 0)
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testNoneDoubleTapTabItemChange() async throws {
        let sut =  SRRootView(context: context) {
            SRTabbarView {
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
