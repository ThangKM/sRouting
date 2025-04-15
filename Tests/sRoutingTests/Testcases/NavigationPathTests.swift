//
//  NavigationPathTests.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import Foundation
import Testing
@testable import sRouting

@Suite("Testing SRNavigationPath")
@MainActor
struct NavigationPathTests {
    
    let path = SRNavigationPath()
    
    @Test
    func testMatchingStack() throws {
        path.push(to: TestRoute.home)
        path.push(to: TestRoute.emptyScreen)
        let stack = path.stack
        #expect(stack.count == 2)
        let firstPath = try #require(stack.first)
        #expect(firstPath.contains(TestRoute.Paths.home.rawValue))
        let lastPath = try #require(stack.last)
        #expect(lastPath.contains(TestRoute.Paths.emptyScreen.rawValue))
    }
    
    @Test
    func testPopToTarget() throws {
        path.push(to: TestRoute.emptyScreen)
        path.push(to: TestRoute.home)
        path.push(to: TestRoute.emptyScreen)
        path.push(to: TestRoute.emptyScreen)
        path.push(to: TestRoute.emptyScreen)
        
        path.pop(to: TestRoute.Paths.home)
        
        let stack = path.stack
        #expect(stack.count == 2)
        let lastPath = try #require(stack.last)
        #expect(lastPath.contains(TestRoute.Paths.home.rawValue))
    }
    
    @Test
    func testPopToRoot() {
        path.push(to: TestRoute.emptyScreen)
        path.push(to: TestRoute.home)
        path.push(to: TestRoute.emptyScreen)
        path.push(to: TestRoute.emptyScreen)
        path.push(to: TestRoute.emptyScreen)

        path.popToRoot()
        #expect(path.stack.isEmpty)
    }
    
    @Test
    func testPop() throws {
        path.push(to: TestRoute.home)
        path.push(to: TestRoute.emptyScreen)

        path.pop()
        let stack = path.stack
        let firstPath = try #require(stack.first)
        #expect(firstPath.contains(TestRoute.Paths.home.stringValue))
        #expect(stack.count == 1)
    }
}


