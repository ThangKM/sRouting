//
//  TestInitializers.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import Testing
import SwiftUI

@testable import sRouting


@Suite("Test SRTransition initializers")
struct TestInitializers {

    @Test
    func testInitialTransitionWithSelectTab() {
        let sut = SRTransition<EmptyRoute>(selectTab: 0)
        #expect(sut.alert == nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == 0)
        #expect(sut.type == .selectTab)
    }
    
    @Test
    func testInitalTrasitionWithType() {
        let sut = SRTransition<EmptyRoute>(with: .dismissAll)
        #expect(sut.alert == nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .dismissAll)
    }
    
    @Test
    func testInitTransitionWithAlert() {
        let sut = SRTransition<EmptyRoute>(with: Alert(title: Text(""), message: Text("message"), dismissButton: nil))
        #expect(sut.alert != nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .alert)
    }
    
    @Test
    func testInitTransitionWithError() {
        let sut = SRTransition<EmptyRoute>(with: NSError(domain: "", code: 1, userInfo: [:]), and: nil)
        #expect(sut.alert != nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .alert)
    }
    
    @Test
    func testInitTransitionWithRoute() {
        let sut = SRTransition<EmptyRoute>(with: .emptyScreen, and: .sheet)
        #expect(sut.route != nil)
        #expect(sut.alert == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .sheet)
    }
    
    @Test
    func testInitTransitionNoneType() throws {
        let sut = SRTransition<EmptyRoute>(with: .none)
        #expect(sut.alert == nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .none)
        #expect(sut == SRTransition.none)
    }

    @Test
    func testInitTransitionType() {
        SRTriggerType.allCases.forEach { triggerType in
            let transitionType = SRTransitionType(with: triggerType)
            #expect(transitionType.rawValue == triggerType.rawValue)
        }
    }
    
    @Test
    func testTransitionType() {
        SRTransitionType.allCases.forEach { type in
            #expect(type.description == "TransitionType - \(type)")
        }
    }
    
    @Test
    func testTriggerType() {
        SRTriggerType.allCases.forEach { type in
            #expect(type.description == "TriggerType - \(type)")
        }
    }
}
