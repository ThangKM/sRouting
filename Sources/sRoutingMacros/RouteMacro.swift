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
        
        let declCoordinator: DeclSyntax = """
            extension \(raw: type.trimmedDescription): sRouting.SRRoute {
            
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
        let extCoordinator = declCoordinator.cast(ExtensionDeclSyntax.self)
        return [extCoordinator]
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
