//
//  RouteObserveMacroTest.swift
//  
//
//  Created by Thang Kieu on 20/8/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import sRouting
import Observation


#if canImport(sRoutingMacros) && os(macOS)
import sRoutingMacros

final class RouteObserveMacroTest: XCTestCase {
    
    @available(macOS 15.0, *)
    func testRouteObserveMacroImp() async throws {
        assertMacroExpansion("""
        @sRouteObserve(HomeRoute.self, SettingRoute.self)
        struct ObserveView<Content: View>: View {
        }
        """, expandedSource:"""
        struct ObserveView<Content: View>: View {

            let content: () -> Content
            let path: SRNavigationPath

            init(path: SRNavigationPath, content: @escaping () -> Content) {
                self.path = path
                self.content = content
            }

            var body: some View {
                content()
                .navigationDestination(for: HomeRoute.self) { route in route.screen }
            .navigationDestination(for: SettingRoute.self) { route in route.screen }

            }
        }

        extension ObserveView: sRouting.SRObserveViewType {
        }
        """,
        macros: testMacros)
    }
    
    @available(macOS 15.0, *)
    func testRouteObserveMacroWhereImp() async throws {
        assertMacroExpansion("""
        @sRouteObserve(HomeRoute.self, SettingRoute.self)
        struct ObserveView<Content>: View where Content: View {
        }
        """, expandedSource:"""
        struct ObserveView<Content>: View where Content: View {

            let content: () -> Content
            let path: SRNavigationPath

            init(path: SRNavigationPath, content: @escaping () -> Content) {
                self.path = path
                self.content = content
            }

            var body: some View {
                content()
                .navigationDestination(for: HomeRoute.self) { route in route.screen }
            .navigationDestination(for: SettingRoute.self) { route in route.screen }

            }
        }

        extension ObserveView: sRouting.SRObserveViewType {
        }
        """,
        macros: testMacros)
    }
    
    func testNoneStructImp() async throws {
        assertMacroExpansion("""
        @sRouteObserve(HomeRoute.self, SettingRoute.self)
        class ObserveView<Content>: View where Content: View {
        }
        """, expandedSource:"""
        class ObserveView<Content>: View where Content: View {
        }

        extension ObserveView: sRouting.SRObserveViewType {
        }
        """,
                             diagnostics: [.init(message: SRMacroError.onlyStruct.description, line: 1, column: 1,severity: .error)],
        macros: testMacros)
    }
    
    func testNoneConentGenericName() async throws {
        assertMacroExpansion("""
        @sRouteObserve(HomeRoute.self, SettingRoute.self)
        struct ObserveView<V>: View where V: View {
        }
        """, expandedSource:"""
        struct ObserveView<V>: View where V: View {
        }

        extension ObserveView: sRouting.SRObserveViewType {
        }
        """,
                             diagnostics: [.init(message: SRMacroError.invalidGenericFormat("ObserveView").description, line: 1, column: 1,severity: .error)],
        macros: testMacros)
    }
    
    func testContentIsNotViewImp() async throws {
        assertMacroExpansion("""
        @sRouteObserve(HomeRoute.self, SettingRoute.self)
        struct ObserveView<Content>: View where Content: Codable {
        }
        """, expandedSource:"""
        struct ObserveView<Content>: View where Content: Codable {
        }

        extension ObserveView: sRouting.SRObserveViewType {
        }
        """,
                             diagnostics: [.init(message: SRMacroError.invalidGenericFormat("ObserveView").description, line: 1, column: 1,severity: .error)],
        macros: testMacros)
    }
    
    func testRouteDuplication() async throws {
        assertMacroExpansion("""
        @sRouteObserve(HomeRoute.self, SettingRoute.self, HomeRoute.self)
        struct ObserveView<Content>: View where Content: View {
        }
        """, expandedSource:"""
        struct ObserveView<Content>: View where Content: View {
        }

        extension ObserveView: sRouting.SRObserveViewType {
        }
        """,
                             diagnostics: [.init(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)],
        macros: testMacros)
    }
}
#endif
