//
//  RouterTests.swift
//  
//
//  Created by ThangKieu on 7/2/21.
//

import SwiftUI
import XCTest
import Combine
import ViewInspector
@testable import sRouting


class RouterTests: XCTestCase {
    
    @MainActor
    func testSelectTabbarItem() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.tabIndex, 3)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.selectTabbar(at: 3)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testTrigger() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .push)
                XCTAssertNotNil(newValue.route)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testShowError() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .alert)
                XCTAssertNotNil(newValue.alert)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.show(error: NSError(domain: "", code: 11, userInfo: nil), and: nil)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testShowAlert() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .alert)
                XCTAssertNotNil(newValue.alert)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.show(alert: .init(title: Text(""), message: Text("message"), dismissButton: nil))
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testDismiss() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .dismiss)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.dismiss()
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testDismissAll() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .dismissAll)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.dismissAll()
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testPop() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .pop)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.pop()
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testPopToRoot() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .popToRoot)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.popToRoot()
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testPopToRoute() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .popToRoute)
                XCTAssertNotNil(newValue.popToRoute)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.pop(to: EmptyRoute.emptyScreen)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testOpenWindowId() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .openWindow)
                XCTAssertEqual(newValue.windowTransition?.windowId, "window_id")
                XCTAssertNil(newValue.windowTransition?.windowValue)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.openWindow(id: "window_id")
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testOpenWindowValue() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .openWindow)
                XCTAssertEqual(newValue.windowTransition?.windowValue?.hashValue, 123.hashValue)
                XCTAssertNil(newValue.windowTransition?.windowId)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.openWindow(value: 123)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testOpenWindowIdAndValue() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .openWindow)
                XCTAssertEqual(newValue.windowTransition?.windowValue?.hashValue, 123.hashValue)
                XCTAssertEqual(newValue.windowTransition?.windowId, "window_id")
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.openWindow(id: "window_id", value: 123)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testOpenURL() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .openURL)
                XCTAssertEqual(newValue.windowTransition?.url?.absoluteString, "www.google.com")
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.openURL(at: URL(string: "www.google.com")!, completion: .none)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    #if os(macOS)
    @MainActor
    func testDocument() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRRootView(dsaEmitter: .init()) {
            TestScreen(router: router, tests: .none).onChange(of: router.transition) { oldValue, newValue in
                XCTAssertEqual(newValue.type, .openDocument)
                XCTAssertEqual(newValue.windowTransition?.url?.absoluteString, "file://user")
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.openDocument(at: URL(string: "file://user")!, completion: .none)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    #endif
}
