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
        
        var caseItems = ""
        let pathCases = arguments.filter({ !$0.hasPrefix(subrouteMacro) })
        for caseName in pathCases {
            caseItems += "case \(caseName) = \"\(prefixPath)_\(caseName.lowercased())\""
            if caseName != pathCases.last {
                caseItems += "\n"
            }
        }
        
        var casePaths = ""
        for caseName in arguments {
            if caseName.hasPrefix(subrouteMacro) {
                guard let name = caseName.split(separator: "_").last else { continue }
                casePaths += "case .\(name)(let route): return route.path"
            } else {
                casePaths += "case .\(caseName): return Paths.\(caseName).rawValue"
                if caseName != arguments.last {
                    casePaths += "\n"
                }
            }
        }
        
        let declExtension: DeclSyntax
        // Difference from RouteMacro: No conformance to sRouting.SRRoute
        if pathCases.isEmpty {
            declExtension = """
            extension \(raw: type.trimmedDescription) {
            
                nonisolated var path: String { 
                    switch self {
                    \(raw: casePaths)
                    }
                }
            }
            """
        } else {
            declExtension = """
            extension \(raw: type.trimmedDescription) {
            
                enum Paths: String, StringRawRepresentable {
                    \(raw: caseItems)
                }
                
                nonisolated var path: String { 
                    switch self {
                    \(raw: casePaths)
                    }
                }
            }
            """
        }
        
        let result = declExtension.cast(ExtensionDeclSyntax.self)
        return [result]
    }
}
