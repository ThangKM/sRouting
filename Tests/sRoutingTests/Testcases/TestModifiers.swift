//
//  TestModifiers.swift
//
//
//  Created by Thang Kieu on 29/03/2024.
//

import Foundation

import XCTest
import ViewInspector
import SwiftUI

@testable import sRouting

class TestModifiers: XCTestCase {
    
    @MainActor
    func testOnDismissAll() async {
        let exp = XCTestExpectation()
        let router = TestRouter()
        let sut = SRRootView(context: SRContext()) {
            TestScreen(router: router, tests: .none).onDismissAllChange {
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.dismissAll()
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testOnNavigationStackChange() async {
        let exp = XCTestExpectation()
        let router = TestRouter()
        let sut = SRRootView(context: SRContext()) {
            SRNavigationStack(path: .init(), observeView: ObserveView.self) {
                TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                    XCTAssertTrue(oldPaths.isEmpty)
                    XCTAssertFalse(newPaths.isEmpty)
                    exp.fulfill()
                }
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testOnTabSelectionChange() async {
        let exp = XCTestExpectation()
        let router = TestRouter()
        let context = SRContext()
        let sut =  SRRootView(context: context) {
            SRTabbarView {
                TestScreen(router: router, tests: .none)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(0)
                    .onTabSelectionChange { value in
                        XCTAssertEqual(value, 1)
                        exp.fulfill()
                    }
                
                TestScreen(router: router, tests: .none).tabItem {
                    Label("Setting", systemImage: "gear")
                }.tag(1)
            }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 1)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testOnDoubleTapTabItemChange() async throws {
        let exp = XCTestExpectation()
        let router = TestRouter()
        let context = SRContext()
        let sut =  SRRootView(context: context) {
            SRTabbarView {
                TestScreen(router: router, tests: .none)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(0)
            }
            .onDoubleTapTabItem { selection in
                XCTAssertEqual(selection, .zero)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 0)
        try await Task.sleep(for: .milliseconds(300))
        router.selectTabbar(at: 0)
        await fulfillment(of: [exp], timeout: 1)
    }
    
    @MainActor
    func testNoneDoubleTapTabItemChange() async throws {
        let router = TestRouter()
        let context = SRContext()
        let sut =  SRRootView(context: context) {
            SRTabbarView {
                TestScreen(router: router, tests: .none)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(0)
            }
            .onDoubleTapTabItem { selection in
                XCTFail()
            }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 0)
        try await Task.sleep(for: .milliseconds(500))
        router.selectTabbar(at: 0)
    }
}
