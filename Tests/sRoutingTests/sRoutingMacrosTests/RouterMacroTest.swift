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


/////Using for dev
//#if canImport(sRoutingMacros) && os(macOS)
//
//import sRoutingMacros
//
//let testMacros: [String: Macro.Type] = [
//    "sRContext": ContextMacro.self, "sRouter": RouterMacro.self, "sRouteObserve": RouteObserveMacro.self
//]
//
//final class RouterMacroTest: XCTestCase {
//
//    func testRouterMacroImp() throws {
//        
//        assertMacroExpansion("""
//        @sRouter(HomeRoute.self) @Observable
//        class HomeViewModel { }
//        """, expandedSource:"""
//        @sRouter(HomeRoute.self) @Observable
//        class HomeViewModel { }
//        """,
//        macros: testMacros)
//    }
//    
//    func testRootRouterMacroImp() throws {
//        assertMacroExpansion("""
//        @sRootRouter(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
//        struct RootRouter { }
//        """, expandedSource:"""
//        @sRootRouter(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
//        struct RootRouter { }
//        """,
//        macros: testMacros)
//    }
//    
//    func testRouteObserveMacroImp() throws {
//        assertMacroExpansion("""
//        @sRouteObserve(HomeRoute.self)
//        struct ObserveView<Content>: View where Content: View { }
//        """, expandedSource:"""
//        @sRouteObserve(HomeRoute.self)
//        struct ObserveView<Content>: View where Content: View { }
//        """,
//        macros: testMacros)
//    }
//}
//
//#endif
