//
//  RouterMacroTest.swift
//
//
//  Created by Thang Kieu on 18/03/2024.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import sRouting
import Observation
import SwiftUI


///Using for dev
#if canImport(sRoutingMacros)

import sRoutingMacros

let testMacros: [String: Macro.Type] = [
    "Router": RouterMacro.self,
]

final class RouterMacroTest: XCTestCase {

    func testRouterMacroImp() throws {
        
        assertMacroExpansion("""
        @sRouter(HomeRoute.self) @Observable
        class HomeViewModel { }
        """, expandedSource:"""
        @sRouter(HomeRoute.self) @Observable
        class HomeViewModel { }
        """,
        macros: testMacros)
    }
}

#endif
