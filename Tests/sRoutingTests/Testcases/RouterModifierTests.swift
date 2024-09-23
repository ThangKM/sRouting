//
//  RouterModifierTests.swift
//
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI
import ViewInspector
import XCTest
@testable import sRouting

class RouterModifierTests: XCTestCase {
        
    @MainActor
    func testActiveSheet() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            XCTAssertTrue(view.isActiveSheet)
            exp.fulfill()
        }))
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .sheet)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testActiveAlert() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            XCTAssertTrue(view.isActiveAlert)
            exp.fulfill()
        }))
        
        ViewHosting.host(view: sut)
        router.show(error: NSError(domain: "unittest.navigator", code: -1, userInfo: [:]), and: nil)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testDismissAll() async {
        let router = TestRouter()
        let exp = XCTestExpectation(description: "wait.dismiss")
        
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            XCTAssertFalse(view.isActiveAlert)
            XCTAssertFalse(view.isActiveSheet)
            XCTAssertFalse(view.isActivePresent)
            XCTAssertFalse(view.isActiveActionSheet)
            exp.fulfill()
        }))
        
        ViewHosting.host(view: sut)
        
        router.dismissAll()
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testPush() async {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = SRNavigationStack(path: .init(), observeView: ObserveView.self) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                XCTAssertTrue(newPaths.count == 1)
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testPop() async {
        let exp = XCTestExpectation()
        let router = TestRouter()
        let sut = SRNavigationStack(path: .init(), observeView: ObserveView.self) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                guard newPaths.count == .zero else { return }
                exp.fulfill()
                
            }
        }
        ViewHosting.host(view: sut)
        Task.detached {
            await router.trigger(to: .emptyScreen, with: .push)
            try await Task.sleep(for:.milliseconds(50))
            await router.pop()
        }
        await fulfillment(of: [exp], timeout: 0.3)
    }
    
    @MainActor
    func testPopToRoot() async {
        let exp = XCTestExpectation()
        let router = TestRouter()
        let sut = SRNavigationStack(path: .init(), observeView: ObserveView.self) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                guard newPaths.count == .zero else { return }
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        Task.detached {
            await router.trigger(to: .home, with: .push)
            await router.trigger(to: .emptyScreen, with: .push)
            await router.trigger(to: .setting, with: .push)
            try await Task.sleep(for:.milliseconds(50))
            await router.popToRoot()
        }
        await fulfillment(of: [exp], timeout: 0.5)
    }
    
    @MainActor
    func testPopToTarget() async {
        let exp = XCTestExpectation()
        let router = TestRouter()
        let sut = SRNavigationStack(path: .init(), observeView: ObserveView.self) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                guard let path = newPaths.first, newPaths.count == 1 else { return }
                XCTAssertTrue(path.contains("home"))
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        Task.detached {
            await router.trigger(to: .home, with: .push)
            await router.trigger(to: .emptyScreen, with: .push)
            await router.trigger(to: .setting, with: .push)
            try await Task.sleep(for:.milliseconds(50))
            await router.pop(to: EmptyRoute.home)
        }
        await fulfillment(of: [exp], timeout: 0.5)
    }
                                                          
    #if os(iOS) || os(tvOS)
    @MainActor
    func testActiveActionSheet() async {
        let router = TestRouter()
        let exp = XCTestExpectation(description: "wait.dismiss")
        
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            XCTAssertTrue(view.isActiveActionSheet)
            exp.fulfill()
        }))
        
        ViewHosting.host(view: sut)
        
        router.show(actionSheet: .init(title: Text("test")))
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    @MainActor
    func testActivePresent() async {
        let router = TestRouter()
        let exp = XCTestExpectation(description: "wait.dismiss")
        
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            XCTAssertTrue(view.isActivePresent)
            exp.fulfill()
        }))
        
        ViewHosting.host(view: sut)
        
        router.trigger(to: .home, with: .present)
        await fulfillment(of: [exp], timeout: 0.2)
    }
    
    #endif
}
