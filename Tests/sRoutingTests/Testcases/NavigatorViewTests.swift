//
//  NavigatorViewTests.swift
//  
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI
import ViewInspector
import XCTest
@testable import sRouting

class NavigatorViewTests: XCTestCase {
    
    @MainActor
    func testActivePush() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRNavigationStack(path: .init()) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                XCTAssertTrue(oldPaths.isEmpty)
                XCTAssertTrue(newPaths.count == 1)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testActiveSheet() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRNavigationStack(path: .init()) {
            NavigatorView(router: router, onDismiss: {}, testsActions: .init(didChangeTransition: { view in
                XCTAssertTrue(view.isActiveSheet)
                exp.fulfill()
            }))
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .sheet)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testActiveAlert() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRNavigationStack(path: .init()) {
            NavigatorView(router: router, onDismiss: {}, testsActions: .init(didChangeTransition: { view in
                XCTAssertTrue(view.isActiveAlert)
                exp.fulfill()
            }))
        }
        
        ViewHosting.host(view: sut)
        router.show(error: NSError(domain: "unittest.navigator", code: -1, userInfo: [:]), and: nil)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testDismiss() async {
        let router = TestRouter()
        let exp = XCTestExpectation(description: "wait.dismiss")
        
        let sut = TestScreen(router: router, tests: .init(dismissAction:{
            exp.fulfill()
        }))
        
        ViewHosting.host(view: sut)
        
        router.dismiss()
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    #if os(iOS) || os(tvOS)
    @MainActor
    func testActiveActionSheet() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let context = SRContext()
        let sut = SRNavigationStack(path: context.navigationPath(of: .home)) {
            NavigatorView(router: router, onDismiss: {}, testsActions: .init(didChangeTransition: { view in
                XCTAssertTrue(view.isActiveSheet)
                exp.fulfill()
            }))
        }
        
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .sheet)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testActivePresent() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let context = SRContext()
        let sut = SRNavigationStack(path: context.navigationPath(of: .home)) {
            NavigatorView(router: router, onDismiss: {}, testsActions: .init(didChangeTransition: { view in
                XCTAssertTrue(view.isActivePresent)
                exp.fulfill()
            }))
        }
        
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .present)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    #endif
}
