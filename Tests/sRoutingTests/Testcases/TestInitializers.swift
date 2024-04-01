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

    @MainActor
    func testInitScreenView() throws {
        let sut = ScreenView(router: TestRouter(), 
                             dismissAction: .none, tests: .none) {
            Text("ScreenView.Text")
        }
        ViewHosting.host(view: sut)
        let text = try sut.inspect().find(text: "ScreenView.Text").string()
        XCTAssertEqual(text, "ScreenView.Text")
    }
    
    @MainActor
    func testInitRootView() throws {
        let view = SRRootView(dsaEmitter: .init()) {
            Text("This is content in RootView")
        }
        ViewHosting.host(view: view)
        let sut = try view.inspect().find(text: "This is content in RootView").string()
        XCTAssertEqual(sut, "This is content in RootView")
    }
    
    @MainActor
    func testInitialTransitionWithSelectTab() throws {
        let sut = SRTransition<EmptyRoute>(selectTab: 0)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertEqual(sut.tabIndex, 0)
        XCTAssertEqual(sut.type, .selectTab)
    }
    
    @MainActor
    func testInitalTrasitionWithType() throws {
        let sut = SRTransition<EmptyRoute>(with: .dismissAll)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .dismissAll)
    }
    
    @MainActor
    func testInitTransitionWithAlert() throws {
        let sut = SRTransition<EmptyRoute>(with: Alert(title: Text(""), message: Text("message"), dismissButton: nil))
        XCTAssertNotNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .alert)
    }
    
    @MainActor
    func testInitTransitionWithError() throws {
        let sut = SRTransition<EmptyRoute>(with: NSError(domain: "", code: 1, userInfo: [:]), and: nil)
        XCTAssertNotNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .alert)
    }
    
    @MainActor
    func testInitTransitionWithRoute() throws {
        let sut = SRTransition<EmptyRoute>(with: .emptyScreen, and: .sheet)
        XCTAssertNotNil(sut.route)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .sheet)
    }
    
    @MainActor
    func testInitTransitionNoneType() throws {
        let sut = SRTransition<EmptyRoute>(with: .none)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.route)
        XCTAssertNil(sut.tabIndex)
        XCTAssertEqual(sut.type, .none)
        XCTAssertEqual(sut, SRTransition.none)
    }
    
    @MainActor
    func testInitTransitionType() throws {
        SRTriggerType.allCases.forEach { triggerType in
            let transitionType = SRTransitionType(with: triggerType)
            XCTAssertEqual(transitionType.rawValue, triggerType.rawValue)
        }
    }
    
    @MainActor
    func testTransitionType() {
        SRTransitionType.allCases.forEach { type in
            XCTAssertEqual(type.description, "TransitionType - \(type)")
        }
    }
    
    @MainActor
    func testTriggerType() {
        SRTriggerType.allCases.forEach { type in
            XCTAssertEqual(type.description, "TriggerType - \(type)")
        }
    }
}
