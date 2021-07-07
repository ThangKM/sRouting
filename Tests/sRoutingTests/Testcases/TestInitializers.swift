//
//  TestInitializers.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import XCTest
import ViewInspector
import SwiftUI

@testable import sRouting

struct TestScreen: View, Inspectable {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    var body: some View {
        let router = Router<EmptyRoute>()
        ScreenView(router: router, presentationMode: presentationMode) {
            Text("TestScreen.ScreenView.Text")
        }
        environmentObject(RootRouter())
    }
}

class TestInitializers: XCTestCase {

    override class func setUp() {
        super.setUp()
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
    func testInitScreenView() throws {
        let view = TestScreen()
        let sut = try view.inspect().find(text: "TestScreen.ScreenView.Text").string()
        XCTAssertEqual(sut, "TestScreen.ScreenView.Text")
    }
    
    func testInitRootView() throws {
        let view = RootView(rootRouter: .init()) {
            Text("This is content in RootView")
        }

        let sut = try view.inspect().find(text: "This is content in RootView").string()
        XCTAssertEqual(sut, "This is content in RootView")
    }
    
    func testInitNavigatorView() throws {
        let sut = NavigatorView(router: Router<EmptyRoute>()) {
            // dismiss callback
        }.environmentObject(RootRouter())
        
        let isHidden = try sut.inspect().view(NavigatorView<EmptyRoute>.self).group().isHidden()
        XCTAssertTrue(isHidden)
    }
    
    func testBindingWillSetExtension() {
        let exp = XCTestExpectation(description: "bindingset")
        let sut = Binding(wrappedValue: false).willSet { value in
            XCTAssertTrue(value)
            exp.fulfill()
        }
        sut.wrappedValue = true
        wait(for: [exp], timeout: 0.2)
    }
    
    func testInitialTransitionWithSelectTab() throws {
        let sut = Transition<EmptyRoute>(selectTab: 0)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertEqual(sut.tabIndex, 0)
        XCTAssertEqual(sut.type, .selectTab)
    }
    
    func testInitalTrasitionWithType() throws {
        let sut = Transition<EmptyRoute>(with: .dismissAll)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .dismissAll)
    }
    
    func testInitTransitionWithAlert() throws {
        let sut = Transition<EmptyRoute>(with: Alert(title: Text(""), message: Text("message"), dismissButton: nil))
        XCTAssertNotNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .alert)
    }
    
    func testInitTransitionWithError() throws {
        let sut = Transition<EmptyRoute>(with: NSError(domain: "", code: 1, userInfo: [:]), and: nil)
        XCTAssertNotNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .alert)
    }
    
    func testInitTransitionWithRoute() throws {
        let sut = Transition<EmptyRoute>(with: .emptyScreen, and: .sheet)
        XCTAssertNotNil(sut.route)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .sheet)
    }
    
    func testInitTransitionNoneType() throws {
        let sut = Transition<EmptyRoute>(with: .none)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .none)
        XCTAssertEqual(sut, Transition.none)
    }
    
    func testInitTransitionType() throws {
        TriggerType.allCases.forEach { triggerType in
            let transitionType = TransitionType(with: triggerType)
            XCTAssertEqual(transitionType.rawValue, triggerType.rawValue)
        }
    }
    
    func testTransitionType() {
        TransitionType.allCases.forEach { type in
            XCTAssertEqual(type.description, "TransitionType - \(type)")
        }
    }
    
    func testTriggerType() {
        TriggerType.allCases.forEach { type in
            XCTAssertEqual(type.description, "TriggerType - \(type)")
        }
    }
    
    func testRootRouterInit() throws {
        let router = RootRouter()
        XCTAssertEqual(router.tabbarSelection, 0)
        XCTAssertEqual(router.dismissAll, 0)
        router.dismissToRoot()
        XCTAssertEqual(router.dismissAll, 1)
    }
}

extension ScreenView : Inspectable { }

extension RootView: Inspectable { }

extension NavigatorView: Inspectable { }
