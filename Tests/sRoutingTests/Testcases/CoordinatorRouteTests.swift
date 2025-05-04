//
//  CoordinatorRouteTests.swift
//  sRouting
//
//  Created by Thang Kieu on 3/5/25.
//

import Testing
import ViewInspector
@testable import sRouting


@Suite("Test CoordinatorRoute")
@MainActor
struct CoordinatorRouteTests {
    
    let context = SRContext()
    let coordinator = Coordinator()
    let router = SRRouter(TestRoute.self)
    
    @Test
    func testOpenCoordinator() async throws {
        let sut = TestCoordinatorView(context: context, coordinator: coordinator, router: router)
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(100))
        router.openCoordinator(route: TestRoute.home, with: .sheet)
        try await Task.sleep(for: .milliseconds(100))
        #expect(context.coordinatorRoute?.route.path == TestRoute.home.path)
        #expect(context.coordinatorRoute?.triggerKind == .sheet)
    }
    
    @Test
    func testInitializer() {
        let route = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        #expect(route.route.path == TestRoute.home.path)
        #expect(route.triggerKind == .sheet)
    }
    
    @Test
    func testEqulity() {
        let route = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        let route2 = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        #expect(route == route2)
    }
    
    @Test
    func testNoneEqulity() async throws {
        let route = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        try await Task.sleep(for: .milliseconds(100))
        let route2 = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        #expect(route != route2)
    }
    
    @Test
    func testHashable() async throws {
        let route = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        try await Task.sleep(for: .milliseconds(100))
        let route2 = CoordinatorRoute(route: TestRoute.home, triggerKind: .sheet)
        #expect(route.hashValue != route2.hashValue)
    }
}
