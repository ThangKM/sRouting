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
        let sut = SRTransition<TestRoute>(selectTab: 0)
        #expect(sut.alert == nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == 0)
        #expect(sut.type == .selectTab)
    }
    
    @Test
    func testInitalTrasitionWithType() {
        let sut = SRTransition<TestRoute>(with: .dismissAll)
        #expect(sut.alert == nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .dismissAll)
    }
    
    @Test
    func testInitTransitionWithAlert() {
        let sut = SRTransition<TestRoute>(with: {
            Alert(title: Text(""), message: Text("message"), dismissButton: nil)
        })
        #expect(sut.alert != nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .alert)
    }
    
    @Test
    func testInitTransitionWithError() {
        let sut = SRTransition<TestRoute>(with: NSError(domain: "", code: 1, userInfo: [:]), and: nil)
        #expect(sut.alert != nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .alert)
    }
    
    @Test
    func testInitTransitionWithRoute() {
        let sut = SRTransition<TestRoute>(with: .emptyScreen, and: .sheet)
        #expect(sut.route != nil)
        #expect(sut.alert == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .sheet)
    }
    
    @Test
    func testInitTransitionNoneType() throws {
        let sut = SRTransition<TestRoute>.none
        #expect(sut.alert == nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex == nil)
        #expect(sut.type == .none)
        #expect(sut == SRTransition.none)
    }

    @Test
    func testInitTransitionType() {
        SRTriggerType.allCases.forEach { triggerType in
            let transitionType = SRTransitionKind(with: triggerType)
            #expect(transitionType.rawValue == triggerType.rawValue)
        }
    }
    
    @Test
    func testTransitionType() {
        SRTransitionKind.allCases.forEach { type in
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
