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
}
