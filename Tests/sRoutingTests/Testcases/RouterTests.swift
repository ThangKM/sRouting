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
    let waiter = Waiter()
    
    @Test
    func testSelectTabbarItem() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none)
                .onChange(of: router.transition) { oldValue, newValue in
                    #expect(newValue.tabIndex == 3)
                    waiter.finish()
                }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 3)
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testTrigger() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .push)
                #expect(newValue.route != nil)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testShowError() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .alert)
                #expect(newValue.alert != nil)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.show(error: NSError(domain: "", code: 11, userInfo: nil), and: nil)
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testShowAlert() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .alert)
                #expect(newValue.alert != nil)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.show(alert: .init(title: Text(""), message: Text("message"), dismissButton: nil))
        try await waiter.await(for: .milliseconds(200))
    }

    @Test
    func testDismiss() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .dismiss)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.dismiss()
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testDismissAll() async throws {
        let sut = SRRootView(context: SRContext()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .dismissAll)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.dismissAll()
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testPop() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .pop)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.pop()
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testPopToRoot() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .popToRoot)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.popToRoot()
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testPopToRoute() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .popToRoute)
                #expect(newValue.popToRoute != nil)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.pop(to: TestRoute.emptyScreen)
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testOpenWindowId() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .openWindow)
                #expect(newValue.windowTransition?.windowId == "window_id")
                #expect(newValue.windowTransition?.windowValue == nil)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.openWindow(windowTrans: .init(windowId: "window_id"))
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testOpenWindowValue() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .openWindow)
                #expect(newValue.windowTransition?.windowValue?.hashValue == 123.hashValue)
                #expect(newValue.windowTransition?.windowId == nil)
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.openWindow(windowTrans: .init(value: 123))
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testOpenWindowIdAndValue() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .openWindow)
                #expect(newValue.windowTransition?.windowValue?.hashValue == 123.hashValue)
                #expect(newValue.windowTransition?.windowId == "window_id")
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.openWindow(windowTrans: .init(windowId: "window_id", value: 123))
        try await waiter.await(for: .milliseconds(200))
    }
    
    @Test
    func testOpenURL() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .openURL)
                #expect(newValue.windowTransition?.url?.absoluteString == "www.google.com")
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.openURL(at: URL(string: "www.google.com")!, completion: .none)
        try await waiter.await(for: .milliseconds(200))
    }
    
    #if os(macOS)
    func testDocument() async throws {
        let sut = SRRootView(context: context) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                #expect(newValue.type == .openDocument)
                #expect(newValue.windowTransition?.url?.absoluteString == "file://user")
                waiter.finish()
            }
        }
        ViewHosting.host(view: sut)
        router.openDocument(at: URL(string: "file://user")!, completion: .none)
        try await waiter.await(for: .milliseconds(200))
    }
    #endif
}
