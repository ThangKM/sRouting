//
//  NavigationPathTests.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import Foundation

import XCTest

@testable import sRouting

class NavigationPathTests: XCTestCase {
    
    
    @MainActor
    func testMatchingStack() async throws {
        let path = SRNavigationPath()
        path.push(to: HomeRoute.home)
        path.push(to: EmptyRoute.emptyScreen)
        let homePath = Helpers.navigationStoredPath(for: HomeRoute.home)
        let emptyPath = Helpers.navigationStoredPath(for: EmptyRoute.emptyScreen)
        let stack = path.stack.map({ $0.replacingOccurrences(of: "sRoutingTests.", with: "")})
        XCTAssertEqual(stack, [homePath, emptyPath])
    }
    
    @MainActor
    func testPopToTarget() async throws {
        let path = SRNavigationPath()
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: HomeRoute.home)
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: EmptyRoute.emptyScreen)
        
        let homePath = Helpers.navigationStoredPath(for: HomeRoute.home)
        let emptyPath = Helpers.navigationStoredPath(for: EmptyRoute.emptyScreen)
        
        path.pop(to: HomeRoute.home)
        
        let stack = path.stack.map({ $0.replacingOccurrences(of: "sRoutingTests.", with: "")})
        XCTAssertEqual(stack, [emptyPath, homePath])
    }
    
    @MainActor
    func testPopToRoot() async throws {
        let path = SRNavigationPath()
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: HomeRoute.home)
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: EmptyRoute.emptyScreen)
        path.push(to: EmptyRoute.emptyScreen)

        path.popToRoot()
        XCTAssertTrue(path.stack.isEmpty)
    }
    
    @MainActor
    func testPop() async throws {
        let path = SRNavigationPath()
        path.push(to: HomeRoute.home)
        path.push(to: EmptyRoute.emptyScreen)

        path.pop()
        let homePath = Helpers.navigationStoredPath(for: HomeRoute.home)
        let stack = path.stack.map({ $0.replacingOccurrences(of: "sRoutingTests.", with: "")})
        XCTAssertEqual(stack, [homePath])
    }
}


