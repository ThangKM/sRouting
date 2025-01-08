//
//  RouteObserverMacroTest.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import sRouting

#if canImport(sRoutingMacros) && os(macOS)
import sRoutingMacros

final class RouteObserverMacroTest: XCTestCase {
    
    func testRouteObserverMacroImp() async throws {
        assertMacroExpansion("""
        @sRouteObserver(HomeRoute.self, SettingRoute.self)
        struct RouteObserver {
        
        }
        """, expandedSource:"""
        struct RouteObserver {

            @EnvironmentObject
            private var path: SRNavigationPath

            init() { }

            @MainActor
            func body(content: Content) -> some View {
                content
                .navigationDestination(for: HomeRoute.self) { route in route.screen.environmentObject(path) }
            .navigationDestination(for: SettingRoute.self) { route in route.screen.environmentObject(path) }

            }

        }

        extension RouteObserver: sRouting.SRRouteObserverType {
        }
        """,
        macros: testMacros)
    }

    func testNoneStructImp() async throws {
        assertMacroExpansion("""
        @sRouteObserver(HomeRoute.self, SettingRoute.self)
        class RouteObserver {
        }
        """, expandedSource:"""
        class RouteObserver {
        }

        extension RouteObserver: sRouting.SRRouteObserverType {
        }
        """,
                             diagnostics: [.init(message: SRMacroError.onlyStruct.description, line: 1, column: 1,severity: .error)],
        macros: testMacros)
    }
    
    func testRouteDuplication() async throws {
        assertMacroExpansion("""
        @sRouteObserver(HomeRoute.self, SettingRoute.self, HomeRoute.self)
        struct RouteObserver {
        }
        """, expandedSource:"""
        struct RouteObserver {
        }

        extension RouteObserver: sRouting.SRRouteObserverType {
        }
        """,
                             diagnostics: [.init(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)],
        macros: testMacros)
    }
}
#endif
