//
//  RouterTests.swift
//  
//
//  Created by ThangKieu on 7/2/21.
//

import SwiftUI
import ViewInspector
import Testing

@testable import sRouting

@Suite("Test Router functionality")
@MainActor
struct RouterTests {
    
    let router = TestRouter()
    let context = SRContext()
    
    @Test
    func testSelectTabbarItem() async throws {
        var tabIndex = 0
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none)
                .onChange(of: router.transition) { oldValue, newValue in
                    tabIndex = newValue.tabIndex ?? -1
                }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 3)
        try await Task.sleep(for: .milliseconds(10))
        #expect(tabIndex == 3)
    }
    
    @Test
    func testTrigger() async throws {
        var transition: SRTransition<TestRoute>?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                transition = newValue
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for: .milliseconds(10))
        let tran = try #require(transition)
        #expect(tran.type == .push)
        #expect(tran.route != nil)
    }
    
    @Test
    func testShowError() async throws {
        var transition: SRTransition<TestRoute>?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                transition = newValue
            }
        }
        ViewHosting.host(view: sut)
        router.show(error: NSError(domain: "", code: 11, userInfo: nil), and: nil)
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.type == .alert)
        #expect(transition?.alert != nil)
    }
    
    @Test
    func testShowAlert() async throws {
        var transition: SRTransition<TestRoute>?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                transition = newValue
            }
        }
        ViewHosting.host(view: sut)
        router.show(alert: .init(title: Text(""), message: Text("message"), dismissButton: nil))
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.type == .alert)
        #expect(transition?.alert != nil)
    }

    @Test
    func testDismiss() async throws {
        var transition: SRTransition<TestRoute>?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                transition = newValue
            }
        }
        ViewHosting.host(view: sut)
        router.dismiss()
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.type == .dismiss)
    }
    
    @Test
    func testDismissAll() async throws {
        var transition: SRTransition<TestRoute>?
        let sut = SRRootView(context: SRContext()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                transition = newValue
            }
        }
        ViewHosting.host(view: sut)
        router.dismissAll()
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.type == .dismissAll)
    }
    
    @Test
    func testPop() async throws {
        var transition: SRTransition<TestRoute>?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                transition = newValue
            }
        }
        ViewHosting.host(view: sut)
        router.pop()
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.type == .pop)
    }
    
    @Test
    func testPopToRoot() async throws {
        var transition: SRTransition<TestRoute>?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                transition = newValue
            }
        }
        ViewHosting.host(view: sut)
        router.popToRoot()
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.type == .popToRoot)
    }
    
    @Test
    func testPopToRoute() async throws {
        var transition: SRTransition<TestRoute>?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                transition = newValue
            }
        }
        ViewHosting.host(view: sut)
        router.pop(to: TestRoute.emptyScreen)
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.type == .popToRoute)
        #expect(transition?.popToRoute != nil)
    }
    
    @Test
    func testOpenWindowId() async throws {
        var transition: SRWindowTransition?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .init(didOpenWindow: { tran in
                transition = tran
            }))
        }
        ViewHosting.host(view: sut)
        router.openWindow(windowTrans: .init(windowId: "window_id"))
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.windowId == "window_id")
        #expect(transition?.windowValue == nil)
    }
    
    @Test
    func testOpenWindowValue() async throws {
        var transition: SRWindowTransition?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .init(didOpenWindow: { tran in
                transition = tran
            }))
        }
        ViewHosting.host(view: sut)
        router.openWindow(windowTrans: .init(value: 123))
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.windowValue?.hashValue == 123.hashValue)
        #expect(transition?.windowId == nil)
    }
    
    @Test
    func testOpenWindowIdAndValue() async throws {
        var transition: SRWindowTransition?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .init(didOpenWindow: { tran in
                transition = tran
            }))
        }
        ViewHosting.host(view: sut)
        router.openWindow(windowTrans: .init(windowId: "window_id", value: 123))
        try await Task.sleep(for: .milliseconds(10))
        #expect(transition?.windowValue?.hashValue == 123.hashValue)
        #expect(transition?.windowId == "window_id")
    }
    
    @Test
    func testOpenURL() async throws {
        var url: URL?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .init(didOpenURL: { _url in
                url = _url
            }))
        }
        ViewHosting.host(view: sut)
        router.openURL(at: URL(string: "www.google.com")!, completion: .none)
        try await Task.sleep(for: .milliseconds(10))
        #expect(url?.absoluteString == "www.google.com")
    }
    
    #if os(macOS)
    @Test
    func testDocument() async throws {
        var url: URL?
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .init(didOpenDoc: { _url in
                url = _url
            }))
        }
        ViewHosting.host(view: sut)
        router.openDocument(at: URL(string: "file://user")!, completion: .none)
        try await Task.sleep(for: .milliseconds(10))
        #expect(url?.absoluteString == "file://user")
    }
    #endif
}
