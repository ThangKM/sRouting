//
//  RoutePathMacroTest.swift
//  sRouting
//
//  Created by Thang Kieu on 15/4/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Observation
@testable import sRouting

#if canImport(sRoutingMacros) && os(macOS)
import sRoutingMacros

final class RoutePathMacroTest: XCTestCase {
    
    func testRoutePathMacroImp() async throws {
        assertMacroExpansion("""
        @sRoutePath
        enum HomeRoute: SRRoute { 
            case message
            case home
            case accountManagement(String)
            case eventSetting
        }
        """, expandedSource: """
        enum HomeRoute: SRRoute { 
            case message
            case home
            case accountManagement(String)
            case eventSetting
        }

        extension HomeRoute {

            enum Paths: String, StringRawRepresentable {
                case message = "hr_message"
                case home = "hr_home"
                case accountManagement = "hr_accountmanagement"
                case eventSetting = "hr_eventsetting"
            }

            nonisolated var path: String {
                switch self {
                case .message:
                    return Paths.message.rawValue
                case .home:
                    return Paths.home.rawValue
                case .accountManagement:
                    return Paths.accountManagement.rawValue
                case .eventSetting:
                    return Paths.eventSetting.rawValue
                }
            }
        }
        """, macros:testMacros)
    }
    
    func testRoutePathMacroHasSubRouteImp() async throws {
        assertMacroExpansion("""
        @sRoutePath
        enum HomeRoute: SRRoute { 
            case message
            case home
            case accountManagement(String)
            @sSubRoute
            case eventSetting(EventRoute)
        }
        """, expandedSource: """
        enum HomeRoute: SRRoute { 
            case message
            case home
            case accountManagement(String)
            case eventSetting(EventRoute)
        }

        extension HomeRoute {

            enum Paths: String, StringRawRepresentable {
                case message = "hr_message"
                case home = "hr_home"
                case accountManagement = "hr_accountmanagement"
            }

            nonisolated var path: String {
                switch self {
                case .message:
                    return Paths.message.rawValue
                case .home:
                    return Paths.home.rawValue
                case .accountManagement:
                    return Paths.accountManagement.rawValue
                case .eventSetting(let route):
                    return route.path
                }
            }
        }
        """, macros:testMacros)
    }
    
    func testRoutePathMacroWithConformanceImp() async throws {
        assertMacroExpansion("""
        @sRoutePath
        enum HomeRoute: SRRoute { 
            case home
        }
        """, expandedSource: """
        enum HomeRoute: SRRoute { 
            case home
        }

        extension HomeRoute {

            enum Paths: String, StringRawRepresentable {
                case home = "hr_home"
            }

            nonisolated var path: String {
                switch self {
                case .home:
                    return Paths.home.rawValue
                }
            }
        }
        """, macros:testMacros)
    }

    func testRoutePathMacroMissingConformanceImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.missingConformance.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRoutePath
        enum HomeRoute {
            case home
        }
        """, expandedSource:"""
        enum HomeRoute {
            case home
        }
        """,
        diagnostics: [dianosSpec],
        macros: testMacros)
    }
}
#endif
