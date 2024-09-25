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
        path.push(to: HomeRoute.home)
        path.push(to: EmptyRoute.emptyScreen)
        let homePath = Helpers.navigationStoredPath(for: HomeRoute.home)
        let emptyPath = Helpers.navigationStoredPath(for: EmptyRoute.emptyScreen)
        let stack = path.stack.map({ $0.replacingOccurrences(of: "sRoutingTests.", with: "")})
        #expect(stack == [homePath, emptyPath])
    }
    
    @Test
    func testPopToTarget() {
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: HomeRoute.home)
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: EmptyRoute.emptyScreen)
        
        let homePath = Helpers.navigationStoredPath(for: HomeRoute.home)
        let emptyPath = Helpers.navigationStoredPath(for: EmptyRoute.emptyScreen)
        
        path.pop(to: HomeRoute.home)
        
        let stack = path.stack.map({ $0.replacingOccurrences(of: "sRoutingTests.", with: "")})
        #expect(stack == [emptyPath, homePath])
    }
    
    @Test
    func testPopToRoot() {
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: HomeRoute.home)
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: EmptyRoute.emptyScreen)

        path.popToRoot()
        #expect(path.stack.isEmpty)
    }
    
    @Test
    func testPop() async throws {
        path.push(to: HomeRoute.home)
        path.push(to: EmptyRoute.emptyScreen)

        path.pop()
        let homePath = Helpers.navigationStoredPath(for: HomeRoute.home)
        let stack = path.stack.map({ $0.replacingOccurrences(of: "sRoutingTests.", with: "")})
        #expect(stack == [homePath])
    }
}


