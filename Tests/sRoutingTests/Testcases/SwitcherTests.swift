//
//  SwitcherTests.swift
//  sRouting
//
//  Created by Thang Kieu on 27/4/25.
//

import Testing
@testable import sRouting

@Suite("Test SRSwitcher functionality")
struct SRSwitcherTests {
    
    @Test
    func testSRSwitcherInitialization() {
        let initialRoute = TestRoute.home
        let switcher = SRSwitcher(route: initialRoute)
        #expect(switcher.route == initialRoute)
    }
    
    @Test
    func testSRSwitcherSwitchToValidRoute() {
        let initialRoute = TestRoute.home
        let newRoute = TestRoute.setting
        let switcher = SRSwitcher(route: initialRoute)
        
        switcher.switchTo(route: newRoute)
        #expect(switcher.route == newRoute, "Switcher should switch to the new route.")
    }

    @Test
    func testSwitcherBoxSwitchToRoute() {
        let initialRoute = TestRoute.home
        let newRoute = TestRoute.setting
        let switcher = SRSwitcher(route: initialRoute)
        let switcherBox = SwitcherBox(switcher: switcher)
        
        switcherBox.switchTo(route: newRoute)
        
        #expect(switcher.route == newRoute)
    }
}
