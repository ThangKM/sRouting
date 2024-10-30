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
    func testMatchingStack() {
        path.push(to: TestRoute.home)
        path.push(to: TestRoute.emptyScreen)
        let homePath = Helpers.navigationStoredPath(for: TestRoute.home)
        let emptyPath = Helpers.navigationStoredPath(for: TestRoute.emptyScreen)
        let stack = path.stack.map({ $0.replacingOccurrences(of: "sRoutingTests.", with: "")})
        #expect(stack == [homePath, emptyPath])
    }
    
    @Test
    func testPopToTarget() {
        path.push(to: TestRoute.emptyScreen)
        path.push(to: TestRoute.home)
        path.push(to: TestRoute.emptyScreen)
        path.push(to: TestRoute.emptyScreen)
        path.push(to: TestRoute.emptyScreen)
        
        let homePath = Helpers.navigationStoredPath(for: TestRoute.home)
        let emptyPath = Helpers.navigationStoredPath(for: TestRoute.emptyScreen)
        
        path.pop(to: TestRoute.home)
        
        let stack = path.stack.map({ $0.replacingOccurrences(of: "sRoutingTests.", with: "")})
        #expect(stack == [emptyPath, homePath])
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
    func testPop() async throws {
        path.push(to: TestRoute.home)
        path.push(to: TestRoute.emptyScreen)

        path.pop()
        let homePath = Helpers.navigationStoredPath(for: TestRoute.home)
        let stack = path.stack.map({ $0.replacingOccurrences(of: "sRoutingTests.", with: "")})
        #expect(stack == [homePath])
    }
}


