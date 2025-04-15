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
        for caseName in arguments {
            caseItems += "case \(caseName) = \"\(prefixPath)_\(caseName.lowercased())\""
            if caseName != arguments.last {
                caseItems += "\n"
            }
        }
        
        var casePaths = ""
        for caseName in arguments {
            casePaths += "case .\(caseName): return Paths.\(caseName).rawValue"
            if caseName != arguments.last {
                casePaths += "\n"
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
                for element in caseDecl.elements {
                    caseNames.append(element.name.text.trimmingCharacters(in: .whitespacesAndNewlines))
                }
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
