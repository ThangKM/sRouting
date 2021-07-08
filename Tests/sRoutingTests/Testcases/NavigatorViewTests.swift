//
//  NavigatorViewTests.swift
//  
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI
import ViewInspector
@testable import sRouting
import XCTest

class NavigatorViewTests: XCTestCase {
    
    func testActivePush() {
        let router = Router<EmptyRoute>()
        let exp = XCTestExpectation()
        let sut = NavigationView {
            NavigatorView(router: router,
                          onDismiss: {},
                          testsActions:.init(didChangeTransition: { view in
                XCTAssertTrue(view.isActivePush)
                exp.fulfill()
            }))
            
        }.environmentObject(RootRouter())
        
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .push)
        wait(for: [exp], timeout: 0.2)
    }
    
    func testActiveSheet() {
        let router = Router<EmptyRoute>()
        let exp = XCTestExpectation()
        let sut = NavigationView {
            NavigatorView(router: router,
                          onDismiss: {},
                          testsActions:.init(didChangeTransition: { view in
                XCTAssertTrue(view.isActiveSheet)
                exp.fulfill()
            }))
            
        }.environmentObject(RootRouter())
        
        ViewHosting.host(view: sut)
        router.trigger(to: .emptyScreen, with: .sheet)
        wait(for: [exp], timeout: 0.2)
    }
    
    func testActiveAlert() {
        let router = Router<EmptyRoute>()
        let exp = XCTestExpectation()
        let sut = NavigationView {
            NavigatorView(router: router,
                          onDismiss: {},
                          testsActions:.init(didChangeTransition: { view in
                XCTAssertTrue(view.isActiveAlert)
                exp.fulfill()
            }))
            
        }.environmentObject(RootRouter())
        
        ViewHosting.host(view: sut)
        
        router.show(error: NSError(domain: "unittest.navigator", code: -1, userInfo: [:]), and: nil)
        wait(for: [exp], timeout: 0.2)
    }
    
    func testResetActiveState() {
        let router = Router<EmptyRoute>()
        let exppush = XCTestExpectation(description: "wait.push")
        let exp = XCTestExpectation(description: "wait.dismissAll")
        
        let sut = NavigationView {
            NavigatorView(router: router,
                          onDismiss: {},
                          testsActions:.init(
            didChangeTransition: { view in
                XCTAssertTrue(view.isActivePush)
                router.dismissAll()
                exppush.fulfill()
            },
            resetActiveState: { view in
                XCTAssertFalse(view.isActivePush)
                XCTAssertFalse(view.isActivePresent)
                XCTAssertFalse(view.isActiveSheet)
                XCTAssertFalse(view.isActiveAlert)
                XCTAssertFalse(view.isActiveActionSheet)
                exp.fulfill()
            }))
            
        }.environmentObject(RootRouter())
        
        ViewHosting.host(view: sut)
        
        router.trigger(to: .emptyScreen, with: .push)
        wait(for: [exppush,exp], timeout: 0.2)
    }
    
    func testDismiss() {
        let router = Router<EmptyRoute>()
        let exp = XCTestExpectation(description: "wait.dismiss")
        
        let sut = NavigationView {
            NavigatorView(router: router,
                          onDismiss: {
                XCTAssertTrue(true)
                exp.fulfill()
            })
            
        }.environmentObject(RootRouter())
        
        ViewHosting.host(view: sut)
        
        router.dismiss()
        wait(for: [exp], timeout: 0.2)
    }
    
    #if os(iOS) || os(tvOS)
    func testActiveActionSheet() {
        let router = Router<EmptyRoute>()
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
        let router = Router<EmptyRoute>()
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
