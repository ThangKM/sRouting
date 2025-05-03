//
//  CoordinatorRouteTests.swift
//  sRouting
//
//  Created by Thang Kieu on 3/5/25.
//

import Testing
@testable import sRouting

@Suite("Test CoordinatorRoute")
struct CoordinatorRouteTests {
    
    func testInitializer() {
        let route = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        #expect(route.route.path == TestRoute.home.path)
        #expect(route.triggerKind == .sheet)
    }
    
    func testEqulity() {
        let route = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        let route2 = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        #expect(route != route2)
    }
    
    func testHashable() {
        let route = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        let route2 = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        #expect(route.hashValue != route2.hashValue)
    }
}
