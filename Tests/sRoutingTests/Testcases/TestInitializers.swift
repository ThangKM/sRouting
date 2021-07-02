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

class TestInitializers: XCTestCase {

    override class func setUp() {
        super.setUp()
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
    func testInitScreenView() throws {
        let view = BlueScreen()
        let sut = try view.inspect().find(text: "BlueScreenText").string()
        XCTAssertEqual(sut, "BlueScreenText")
    }
    
    func testInitRootView() throws {
        let view = RootView(rootRouter: .init()) {
            Text("This is content in RootView")
        }

        let sut = try view.inspect().find(text: "This is content in RootView").string()
        XCTAssertEqual(sut, "This is content in RootView")
    }
    
    func testInitNavigatorView() throws {
        let sut = NavigatorView(router: Router<ColorScreenRoute>()) {
            // dismiss callback
        }.environmentObject(RootRouter())
        
        let isHidden = try sut.inspect().view(NavigatorView<ColorScreenRoute>.self).group().isHidden()
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
        let sut = Transition<ColorScreenRoute>(selectTab: 0)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.screenView)
        XCTAssertEqual(sut.tabIndex, 0)
        XCTAssertEqual(sut.type, .selectTab)
    }
    
    func testInitalTrasitionWithType() throws {
        let sut = Transition<ColorScreenRoute>(with: .dismissAll)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.screenView)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .dismissAll)
    }
    
    func testInitTransitionWithAlert() throws {
        let sut = Transition<ColorScreenRoute>(with: Alert(title: Text(""), message: Text("message"), dismissButton: nil))
        XCTAssertNotNil(sut.alert)
        XCTAssertNil(sut.screenView)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .alert)
    }
    
    func testInitTransitionWithError() throws {
        let sut = Transition<ColorScreenRoute>(with: NSError(domain: "", code: 1, userInfo: [:]), and: nil)
        XCTAssertNotNil(sut.alert)
        XCTAssertNil(sut.screenView)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .alert)
    }
    
    func testInitTransitionWithRoute() throws {
        let sut = Transition<ColorScreenRoute>(with: ColorScreenRoute.blueScreen, and: .sheet)
        XCTAssertNotNil(sut.screenView)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .sheet)
    }
    
    func testInitTransitionNoneType() throws {
        let sut = Transition<ColorScreenRoute>(with: .none)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.screenView)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .none)
        XCTAssertEqual(sut, Transition.none)
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
}

extension ScreenView : Inspectable { }

extension RootView: Inspectable { }

extension NavigatorView: Inspectable { }
