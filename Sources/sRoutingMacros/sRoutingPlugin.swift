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
        RouterMacro.self, ContextMacro.self, RouteObserveMacro.self
    ]
}

public enum SRMacroError: Error, CustomStringConvertible, CustomNSError {
    
    case onlyStruct
    case missingArguments
    case invalidGenericFormat(String)
    case haveToUsingMemberAccess
    case duplication
    case structOrClass
    case onlyClass
    case invalidRouteType
    case missingObservable
    
    public static var errorDomain: String { "com.srouting.macro" }
    
    public var errorCode: Int {
        switch self {
        case .onlyStruct:
            -500
        case .missingArguments:
            -501
        case .invalidGenericFormat:
            -502
        case .haveToUsingMemberAccess:
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
        }
    }
    
    public var description: String {
        switch self {
        case .onlyStruct:
            "Only support for struct!"
        case .missingArguments:
            "Missing arguments!"
        case .invalidGenericFormat(let name):
            "Using 'struct \(name)<Content>: View where Content: View' instead of!"
        case .haveToUsingMemberAccess:
            "Using `YourRoute.self` instead of!"
        case .duplication:
            "Duplication!"
        case .structOrClass:
            "Support for class or struct!"
        case .onlyClass:
            "Only support for class!"
        case .invalidRouteType:
            "Requires route type conform to SRRoute!"
        case .missingObservable:
            "Missing @Observable marco!"
        }
    }
    
    public var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: description]
    }
}
