//
//  TestSwitchView.swift
//  sRouting
//
//  Created by Thang Kieu on 27/4/25.
//

import Testing
import ViewInspector
@testable import sRouting

@Suite("Test SRSwitchView") @MainActor
struct SwitchViewTests {
    
    let router = SRRouter(AppRoute.self)
    let coordinator = Coordinator()
    let context = SRContext()
    
    @Test
    func testSwitchView() {
        let sut = SRRootView(context: context, coordinator: coordinator) {
            SRSwitchView(startingWith: AppRoute.main(router))
        }
        ViewHosting.host(view: sut)
        router.switchTo(route: AppRoute.login)
    }
    
    @Test
    func testSwitchRouteView() async throws {
        let waiter = Waiter()
        let sut = SRRootView(context: context, coordinator: coordinator) {
            SRSwitchRouteView(startingWith: AppRoute.main(router)) { route in
                if route == AppRoute.login {
                    waiter.fulfill()
                }
                return route.screen
            }
        }
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .microseconds(100))
        router.switchTo(route: AppRoute.login)
        try await waiter.waiting(timeout: .seconds(1))
    }
}
