//
//  RouteMacro.swift
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

package struct RouteMacro: ExtensionMacro {
    
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        guard let enumDecl = declaration.as(EnumDeclSyntax.self)
        else { throw SRMacroError.onlyEnum }
        
        let inheritedTypes = Self.extractInheritedTypes(from: enumDecl)
        guard !inheritedTypes.contains(srrouteType) else { throw SRMacroError.redundantConformance }
        
        let arguments = try Self.extractEnumCases(from: enumDecl)
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

        let declExtension = try ExtensionDeclSyntax("extension \(type.trimmed): sRouting.SRRoute") {
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


//MARK: - Helpers
extension RouteMacro {
    
    package static func extractEnumCases(from enumDecl: EnumDeclSyntax) throws -> [String]{
        
        var caseNames: [String] = []
        for member in enumDecl.memberBlock.members {
            if let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) {
                var casename: String = ""
                if let subRoute = caseDecl.attributes.first?.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text.trimmingCharacters(in: .whitespacesAndNewlines),
                   subRoute == subrouteMacro {
                    casename = "\(subrouteMacro)_"
                }
                
                guard let element = caseDecl.elements.first else { continue }
                let name = element.name.text.trimmingCharacters(in: .whitespacesAndNewlines)
                casename += name
                caseNames.append(casename)
            }
        }
        
        guard caseNames.count == Set(caseNames).count else {
            throw SRMacroError.duplication
        }
        
        guard !caseNames.isEmpty else {
            throw SRMacroError.noneRoutes
        }
        
        return caseNames
    }
    
    package static func extractInheritedTypes(from decl: EnumDeclSyntax) -> [String] {
        guard let inheritanceClause = decl.inheritanceClause  else {
            return []
        }
        return inheritanceClause.inheritedTypes.map {
            $0.type.trimmedDescription
        }
    }
}


//MARK: - SubRouteMacro
package struct SubRouteMacro: PeerMacro {
    package static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                  providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                  in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        try validate(of: declaration)
        return []
    }
    
    package static func validate(of declaration: some SwiftSyntax.DeclSyntaxProtocol) throws {
        guard let enumcaseDecl = declaration.as(EnumCaseDeclSyntax.self) else {
            throw SRMacroError.onlyCaseinAnEnum
        }
        guard let element = enumcaseDecl.elements.first else { throw SRMacroError.onlyCaseinAnEnum }
        guard let params = element.parameterClause?.parameters, !params.isEmpty else {
            throw SRMacroError.subRouteNotFound
        }
        guard params.count == 1 else {
            throw SRMacroError.declareSubRouteMustBeOnlyOne
        }
    }
}
