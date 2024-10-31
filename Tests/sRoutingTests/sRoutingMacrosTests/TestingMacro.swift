//
//  TestingMacro.swift
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



#if canImport(sRoutingMacros) && os(macOS)

import sRoutingMacros

let testMacros: [String: Macro.Type] = [
    "sRContext": ContextMacro.self, "sRouter": RouterMacro.self, "sRouteObserver": RouteObserverMacro.self
]

#endif
