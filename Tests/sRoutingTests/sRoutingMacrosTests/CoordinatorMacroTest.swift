//
//  CoordinatorMacroTest.swift
//
//
//  Created by Thang Kieu on 20/8/24.
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

final class CoordinatorMacroTest: XCTestCase {
    
    func testCoordinatorMacroImp() async throws {
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
        class Coordinator { 
        
        }
        """, expandedSource: """
        class Coordinator { 

            let identifier: String

            @MainActor let rootRouter = SRRouter(AnyRoute.self)

            @MainActor let emitter = SRCoordinatorEmitter()

            @MainActor private lazy var navStacks = [SRNavStack.home: SRNavigationPath(coordinator: self), SRNavStack.setting: SRNavigationPath(coordinator: self)]

            @MainActor
            var homePath: SRNavigationPath {
                navStacks[SRNavStack.home]!
            }

            @MainActor
            var settingPath: SRNavigationPath {
                navStacks[SRNavStack.setting]!
            }

            @MainActor var navigationStacks: [SRNavigationPath] {
                navStacks.map(\\.value)
            }

            @MainActor private(set) var activeNavigation: SRNavigationPath?

            @MainActor init() {
                self.identifier = "Coordinator" + "_" + UUID().uuidString
            }

            @MainActor
            func registerActiveNavigation(_ navigationPath: SRNavigationPath) {
                activeNavigation = navigationPath
            }

        }

        extension Coordinator: sRouting.SRRouteCoordinatorType {

            enum SRTabItem: Int, IntRawRepresentable {
                case homeItem
                case settingItem
            }

            enum SRNavStack: String, Sendable {
                case home
                case setting
            }
        }
        """, macros:testMacros)
    }
    
    func testNoneStructOrClassImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.onlyClass.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
        enum Coordinator {
        }
        """, expandedSource:"""
        enum Coordinator {
        }
        """,
        diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
    
    func testMissingArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.missingArguments.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: [], stacks: "")
        class Coordinator {
        }
        """, expandedSource:"""
        class Coordinator {
        }
        """,
        diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
    
    func testTabItemDuplicationArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: ["home","home"], stacks: "home")
        class Coordinator {
        }
        """, expandedSource:"""
        class Coordinator {
        }
        """,
        diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
    
    func testStackDuplicationArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: ["home", "setting"], stacks: "home", "setting", "home")
        class Coordinator {
        }
        """, expandedSource:"""
        class Coordinator {
        }
        """,
        diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
}
#endif
