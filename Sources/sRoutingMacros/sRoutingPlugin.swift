//
//  sRoutingPlugin.swift
//
//
//  Created by Thang Kieu on 18/03/2024.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct sRoutingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RouteCoordinatorMacro.self, RouteObserverMacro.self, RouteMacro.self, SubRouteMacro.self
    ]
}

package enum SRMacroError: Error, CustomStringConvertible, CustomNSError {
    
    case onlyStruct
    case onlyEnum
    case missingArguments
    case invalidGenericFormat(String)
    case haveToUseMemberAccess
    case duplication
    case structOrClass
    case onlyClass
    case invalidRouteType
    case missingObservable
    case noneRoutes
    case redundantConformance
    
    package static var errorDomain: String { "com.srouting.macro" }
    
    package var errorCode: Int {
        switch self {
        case .onlyStruct:
            -500
        case .missingArguments:
            -501
        case .invalidGenericFormat:
            -502
        case .haveToUseMemberAccess:
            -503
        case .duplication:
            -504
        case .structOrClass:
            -505
        case .onlyClass:
            -506
        case .invalidRouteType:
            -507
        case .missingObservable:
            -508
        case .onlyEnum:
            -509
        case .noneRoutes:
            -510
        case .redundantConformance:
            -511
        }
    }
    
    package var description: String {
        switch self {
        case .onlyEnum:
            return "Only enums are supported."
        case .onlyStruct:
            return "Only structs are supported."
        case .missingArguments:
            return "Missing arguments."
        case .invalidGenericFormat(let name):
            return "Use 'struct \(name)<Content>: View where Content: View' instead."
        case .haveToUseMemberAccess:
            return "Use `YourRoute.self` instead."
        case .duplication:
            return "Duplicate definition."
        case .structOrClass:
            return "Only structs or classes are supported."
        case .onlyClass:
            return "Only classes are supported."
        case .invalidRouteType:
            return "Route type must conform to SRRoute."
        case .missingObservable:
            return "Missing @Observable macro."
        case .noneRoutes:
            return "Empty route declaration."
        case .redundantConformance:
            return "Redundant conformance to SRRoute."
        }
    }
    
    package var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: description]
    }
}
