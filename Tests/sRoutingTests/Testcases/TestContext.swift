//
//  TestContext.swift
//  sRouting
//
//  Created by Thang Kieu on 6/4/25.
//

@testable import sRouting
import Foundation
import Testing
import ViewInspector

@Suite("SRContext Tests")
@MainActor
struct TestContext {
    
    let context = SRContext()
    let coordinator = Coordinator()
    let router = SRRouter(TestRoute.self)
    
    @Test
    func testRouting() async throws {
        let sut = SRRootView(context: context, coordinator: coordinator) {
            NavigationRootView(path: coordinator.testStackPath) {
                TestScreen(router: router, tests: .none)
            }
        }
        
        ViewHosting.host(view: sut)
        
        await context.routing(.push(route: TestRoute.emptyScreen),
                              .dismissAll,
                              .popToRoot, .push(route: TestRoute.home),
                              .push(route: TestRoute.setting))
        #expect(coordinator.testStackPath.navPath.count == 2)
        let lastPath = try #require(coordinator.testStackPath.stack.last)
        #expect(lastPath.contains(TestRoute.setting.path))
    }
    
    @Test
    func testDismissAll() {
        #expect(context.dismissAllSignal == false)
        context.dismissAll()
        #expect(context.dismissAllSignal == true)
    }
    
    @Test
    func testOpenCoordinator() {
        context.openCoordinator(.init(route: TestRoute.home, triggerKind: .sheet))
        #expect(context.coordinatorRoute?.route.path == TestRoute.home.path)
        #expect(context.coordinatorRoute?.triggerKind == .sheet)
    }
    
    @Test
    func testRegisterCoordinator() {
        context.registerActiveCoordinator(coordinator)
        #expect(context.coordinatorCount == 1)
    }
    
    @Test
    func testTopCoordinator() async throws {
        context.registerActiveCoordinator(coordinator)
        try await Task.sleep(for: .milliseconds(100))
        let other = Coordinator()
        context.registerActiveCoordinator(other)
        #expect(context.coordinatorCount == 2)
        #expect(context.topCoordinator === other)
    }
    
    @Test
    func resignActiveCoordinator() async throws {
        context.registerActiveCoordinator(coordinator)
        try await Task.sleep(for: .milliseconds(100))
        let other = Coordinator()
        context.registerActiveCoordinator(other)
        #expect(context.coordinatorCount == 2)
        context.resignActiveCoordinator(identifier: other.identifier)
        #expect(context.coordinatorCount == 1)
        #expect(context.topCoordinator === coordinator)
    }
}
