//
//  RoutePathMacro.swift
//  sRouting
//
//  Created by Thang Kieu on 15/4/25.
//

import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

private let srrouteType = "SRRoute"
private let subrouteMacro = "sSubRoute"

package struct RoutePathMacro: ExtensionMacro {
    
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        guard let enumDecl = declaration.as(EnumDeclSyntax.self)
        else { throw SRMacroError.onlyEnum }
        
        // We don't check for redundant conformance here because the user is expected to implement SRRoute manually.
        let inheritedTypes = RouteMacro.extractInheritedTypes(from: enumDecl)
        guard inheritedTypes.contains(srrouteType) else { throw SRMacroError.missingConformance }
        
        let arguments = try RouteMacro.extractEnumCases(from: enumDecl)
        let prefixPath = type.trimmedDescription.filter(\.isUppercase).lowercased()
        
        let pathCases = arguments.filter({ !$0.hasPrefix(subrouteMacro) })

        let pathProperty = try VariableDeclSyntax("nonisolated var path: String") {
            try SwitchExprSyntax("switch self") {
                for caseName in arguments {
                    if caseName.hasPrefix(subrouteMacro) {
                        if let name = caseName.split(separator: "_").last {
                            SwitchCaseSyntax("case .\(raw: name)(let route):") {
                                StmtSyntax("return route.path")
                            }
                        }
                    } else {
                        SwitchCaseSyntax("case .\(raw: caseName):") {
                            StmtSyntax("return Paths.\(raw: caseName).rawValue")
                        }
                    }
                }
            }
        }

        // Difference from RouteMacro: No conformance to sRouting.SRRoute
        let declExtension = try ExtensionDeclSyntax("extension \(type.trimmed)") {
            if !pathCases.isEmpty {
                try EnumDeclSyntax("enum Paths: String, StringRawRepresentable") {
                    for caseName in pathCases {
                        DeclSyntax("case \(raw: caseName) = \(literal: "\(prefixPath)_\(caseName.lowercased())")")
                    }
                }
                .with(\.leadingTrivia, .newlines(2))
            }
            pathProperty.with(\.leadingTrivia, .newlines(2))
        }

        return [declExtension]
    }
}
