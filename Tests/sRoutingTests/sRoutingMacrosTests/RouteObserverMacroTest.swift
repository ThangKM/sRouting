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
import Testing
@testable import sRouting

#if canImport(sRoutingMacros) && os(macOS)
import sRoutingMacros

@Suite("Test RouteObserverMacro")
struct RouteObserverMacroTest {
    
    @Test
    func testRouteObserverMacroImp() async throws {
        assertMacroExpansion("""
        @sRouteObserver(HomeRoute.self, SettingRoute.self, HomeRoute.self)
        struct RouteObserver {
        
        }
        """, expandedSource:"""
        struct RouteObserver {
            @Environment(SRNavigationPath.self)
            private var path

            init() { }

            @MainActor
            func body(content: Content) -> some View {
                content
                .navigationDestination(for: HomeRoute.self) { route in route.screen.environment(path) }
            .navigationDestination(for: SettingRoute.self) { route in route.screen.environment(path) }

            }
        }

        extension RouteObserver: sRouting.SRRouteObserverType {
        }
        """,
        macros: testMacros)
    }

    @Test
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
    
    @Test
    func testRouteDuplication() async throws {
        assertMacroExpansion("""
        @sRouteObserver(HomeRoute.self, SettingRoute.self, HomeRoute.self)
        class RouteObserver {
        }
        """, expandedSource:"""
        class RouteObserver {
        }

        extension RouteObserver: sRouting.SRRouteObserverType {
        }
        """,
                             diagnostics: [.init(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)],
        macros: testMacros)
    }
}
#endif
