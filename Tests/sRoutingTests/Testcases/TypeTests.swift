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
struct TypeTests {
    
    @Test @MainActor
    func testAnyRoute() {
        let route = AnyRoute(route: TestRoute.home)
        #expect(route.screen != nil)
        #expect(route.path.contains(TestRoute.home.path))
    }
    
    @Test
    func testSRRoutingError() {
        let error = SRRoutingError.unsupportedDecodable
        #expect(error.errorCode < .zero)
        #expect(error.localizedDescription == error.description)
        #expect(SRRoutingError.errorDomain == "com.srouting")
    }
}



