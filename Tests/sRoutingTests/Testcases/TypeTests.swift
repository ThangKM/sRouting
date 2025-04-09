//
//  TypeTests.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import Testing
import SwiftUI

@testable import sRouting

@Suite("Test AnyRoute and SRRoutingError")
@MainActor
struct TypeTests {
    
    @Test
    func testAnyRoute() {
        let route = AnyRoute(route: TestRoute.home)
        #expect(route.path.contains(TestRoute.home.path))
    }
    
    @Test
    func testSRRoutingError() {
        let error = SRRoutingError.unsupportedDecodable
        #expect(error.errorCode < .zero)
        #expect(error.localizedDescription == error.description)
        #expect(SRRoutingError.errorDomain == "com.srouting")
    }
    
    @Test
    func testSRAlertRoute() {
        let route = TestErrorRoute.timeOut
        #expect(route.titleKey == "Error")
    }
    
    @Test
    func testDefaultAlertRoute() {
        let route = AlertEmptyRoute()
        #expect(route.titleKey  == "Alert")
    }
    
    @Test
    func testDialog() async throws {
        let route = TestDialog.confirmOK
        #expect(route.titleKey  == "Confirm")
        #expect(route.titleVisibility == .visible)
    }
    
    @Test
    func testDefaultDialog() async throws {
        let route = ConfirmationDialogEmptyRoute()
        #expect(route.titleKey == "")
        #expect(route.titleVisibility == .hidden)
    }
}



