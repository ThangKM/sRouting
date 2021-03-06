//
//  RouterTests.swift
//  
//
//  Created by ThangKieu on 7/2/21.
//

import SwiftUI
import XCTest
import Combine
@testable import sRouting


class RouterTests: XCTestCase {
    
    func testSelectTabbarItem() {
        let router: Router<EmptyRoute> = .init()
        var bag = [AnyCancellable]()
        let exp = XCTestExpectation()
        
        router.objectWillChange
            .sink { _ in
                XCTAssertEqual(router.transition.type, .selectTab)
                XCTAssertEqual(router.transition.tabIndex, 3)
                exp.fulfill()
            }
            .store(in: &bag)
        router.selectTabbar(at: 3)
        wait(for: [exp], timeout: 0.2)
    }
    
    func testTrigger() {
        let router: Router<EmptyRoute> = .init()
        var bag = [AnyCancellable]()
        let exp = XCTestExpectation()
        
        router.objectWillChange
            .sink { _ in
                XCTAssertEqual(router.transition.type, .push)
                XCTAssertNotNil(router.transition.route)
                exp.fulfill()
            }
            .store(in: &bag)
        router.trigger(to: .emptyScreen, with: .push)
        wait(for: [exp], timeout: 0.2)
    }
    
    func testShowError() {
        let router: Router<EmptyRoute> = .init()
        var bag = [AnyCancellable]()
        let exp = XCTestExpectation()
        
        router.objectWillChange
            .sink { _ in
                XCTAssertEqual(router.transition.type, .alert)
                XCTAssertNotNil(router.transition.alert)
                exp.fulfill()
            }
            .store(in: &bag)
        router.show(error: NSError(domain: "", code: 11, userInfo: nil), and: nil)
        wait(for: [exp], timeout: 0.2)
      
    }
    
    func testShowAlert() {
        let router: Router<EmptyRoute> = .init()
        var bag = [AnyCancellable]()
        let exp = XCTestExpectation()
        
        router.objectWillChange
            .sink { _ in
                XCTAssertEqual(router.transition.type, .alert)
                XCTAssertNotNil(router.transition.alert)
                exp.fulfill()
            }
            .store(in: &bag)
        router.show(alert: .init(title: Text(""), message: Text("message"), dismissButton: nil))
        wait(for: [exp], timeout: 0.2)
    }
    
    func testDismiss() {
        let router: Router<EmptyRoute> = .init()
        var bag = [AnyCancellable]()
        let exp = XCTestExpectation()
        
        router.objectWillChange
            .sink { _ in
                XCTAssertEqual(router.transition.type, .dismiss)
                exp.fulfill()
            }
            .store(in: &bag)
        router.dismiss()
        wait(for: [exp], timeout: 0.2)
    }
    
    func testDismissAll() {
        let router: Router<EmptyRoute> = .init()
        var bag = [AnyCancellable]()
        let exp = XCTestExpectation()
        
        router.objectWillChange
            .sink { _ in
                XCTAssertEqual(router.transition.type, .dismissAll)
                exp.fulfill()
            }
            .store(in: &bag)
        router.dismissAll()
        wait(for: [exp], timeout: 0.2)
    }
    
    func testResetTransition() {
        let router: Router<EmptyRoute> = .init()
        var bag = [AnyCancellable]()
        let exp = XCTestExpectation()
        router.objectWillChange
            .sink { _ in
                XCTAssertTrue(false)
                exp.fulfill()
            }
            .store(in: &bag)
        router.resetTransition(scenePhase: .active)
        let result = XCTWaiter.wait(for: [exp], timeout: 0.2)
        if result == .timedOut {
            XCTAssertEqual(router.transition.type, .none)
        } else {
            XCTAssertTrue(false)
        }
    }
}
