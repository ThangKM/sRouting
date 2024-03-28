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
        let sut = SRNavigationStack {
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
        let sut = SRNavigationStack {
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
        let sut = SRNavigationStack {
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
    func testActiveActionSheet() {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = NavigationView {
            NavigatorView(router: router,
                          onDismiss: {},
                          testsActions:.init(didChangeTransition: { view in
                XCTAssertTrue(view.isActiveActionSheet)
                exp.fulfill()
            }))
            
        }.environmentObject(RootRouter())
        
        ViewHosting.host(view: sut)
        router.show(actionSheet: .init(title: Text("test"), message: nil))
        wait(for: [exp], timeout: 0.2)
    }
    
    func testActivePresent()  {
        let router = TestRouter()
        let exp = XCTestExpectation()
        let sut = NavigationView {
            NavigatorView(router: router,
                          onDismiss: {},
                          testsActions:.init(didChangeTransition: { view in
                XCTAssertTrue(view.isActivePresent)
                exp.fulfill()
            }))
            
        }.environmentObject(RootRouter())
        
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .present)
        wait(for: [exp], timeout: 0.2)
    }
    
    #endif
}
