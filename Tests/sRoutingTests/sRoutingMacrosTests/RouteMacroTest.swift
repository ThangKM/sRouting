//
//  RouteMacroTest.swift
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

final class RouteMacroTest: XCTestCase {
    
    func testRouteMacroImp() async throws {
        assertMacroExpansion("""
        @sRoute
        enum HomeRoute { 
            case message
            case home
            case accountManagement(String)
            case eventSetting
        }
        """, expandedSource: """
        enum HomeRoute { 
            case message
            case home
            case accountManagement(String)
            case eventSetting
        }

        extension HomeRoute: sRouting.SRRoute {

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
    
    func testNoneEnumImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.onlyEnum.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRoute
        struct HomeRoute {
        }
        """, expandedSource:"""
        struct HomeRoute {
        }
        """,
        diagnostics: [dianosSpec],
        macros: testMacros)
    }
    
    func testCasesDuplicationArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRoute
        enum HomeRoute {
            case home
            case home(String)
        }
        """, expandedSource:"""
        enum HomeRoute {
            case home
            case home(String)
        }
        """,
        diagnostics: [dianosSpec],
        macros: testMacros)
    }
    
    func testRedudantConformanceImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.redundantConformance.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRoute
        enum HomeRoute: SRRoute {
            case home
            case home(String)
        }
        """, expandedSource:"""
        enum HomeRoute: SRRoute {
            case home
            case home(String)
        }
        """,
        diagnostics: [dianosSpec],
        macros: testMacros)
    }
    
    func testEmptyEnumImp() async throws {
        let dianosSpec = DiagnosticSpec(message: SRMacroError.noneRoutes.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRoute
        enum HomeRoute {

        }
        """, expandedSource:"""
        enum HomeRoute {

        }
        """,
        diagnostics: [dianosSpec],
        macros: testMacros)
    }
}
#endif
