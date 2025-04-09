//
//  TestInitializers.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import Testing
import SwiftUI
import ViewInspector

@testable import sRouting


@Suite("Test SRTransition initializers")
@MainActor
struct TestInitializers {

    let coordinator = Coordinator()
    
    @Test
    func testInitialTransitionWithSelectTab() {
        let sut = SRTransition<TestRoute>(selectTab: Coordinator.SRTabItem.setting)
        #expect(sut.alert == nil)
        #expect(sut.route == nil)
        #expect(sut.tabIndex?.intValue == Coordinator.SRTabItem.setting.intValue)
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
        let sut = SRTransition<TestRoute>.init(with: .timeOut)
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
    
    @Test
    func testInitialNavigaitonStack() async {
        let sut = NavigationStack(path: coordinator.testStackPath) {
            Text("screen")
                .routeObserver(RouteObserver.self)
        }
        ViewHosting.host(view: sut)
    }
}
