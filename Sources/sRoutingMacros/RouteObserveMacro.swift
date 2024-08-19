//
//  RouteObserveMacro.swift
//
//
//  Created by Thang Kieu on 19/8/24.
//

import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros
import Foundation

public enum RouteObserveMacroError: Error, CustomStringConvertible {
    
    case unsupported
    case missingArguments
    case invalidGenericFormat(String)
    case haveToUsingMemberAccess
    case duplication
    
    public var description: String {
        switch self {
        case .unsupported:
            return "Only support for struct!"
        case .missingArguments:
            return "Missing arguments!"
        case .invalidGenericFormat(let name):
            return "Using 'struct \(name)<Content>: View where Content: View' instead of!"
        case .haveToUsingMemberAccess:
            return "Using `YourRoute.self` instead of!"
        case .duplication:
            return "Duplication!"
        }
    }
}

private var genericContent = "Content"

public struct RouteObserveMacro: MemberMacro {
    
    
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        try _validateDeclaration(declaration)
        
        let routes = try Self._arguments(of: node)
        
        var destinationObserve = ""
        for route in routes {
            destinationObserve += ".navigationDestination(for: \(route).self) { route in route.screen.environment(path) }\n"
        }
        
        let decl: DeclSyntax = """
        
        let content: () -> Content
        let path: SRNavigationPath
                
        init(path: SRNavigationPath, content: @escaping () -> Content) {
            self.path = path
            self.content = content
        }
        
        var body: some View {
            content()
            \(raw: destinationObserve)
        }
        """
        return [decl]
    }
}

extension RouteObserveMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let decl: DeclSyntax = """
            extension \(raw: type.trimmedDescription): sRouting.SRObserveViewType {}
            """
        let ext = decl.cast(ExtensionDeclSyntax.self)
        
        return [ext]
    }
}


extension RouteObserveMacro {
    
    private static func _arguments(of node: AttributeSyntax) throws -> Set<String> {
        
        guard case let .argumentList(arguments) = node.arguments, !arguments.isEmpty
        else { throw RouteObserveMacroError.missingArguments }
        
        var routes = [String]()
        for labeled in arguments {
            guard let exp = labeled.expression.as(MemberAccessExprSyntax.self),
                  let base = exp.base?.as(DeclReferenceExprSyntax.self)
            else { throw RouteObserveMacroError.haveToUsingMemberAccess }
            
            let declName = exp.declName.baseName
            guard declName.text == "self"
            else { throw RouteObserveMacroError.haveToUsingMemberAccess }
            
            let input = base.baseName.text
            routes.append(input)
        }
        
        guard !routes.isEmpty else { throw RouteObserveMacroError.missingArguments }
        let setRoutes = Set(routes)
        guard setRoutes.count == routes.count
        else { throw RouteObserveMacroError.duplication }
        return setRoutes
    }
    
    private static func _validateDeclaration(_ declaration: DeclGroupSyntax) throws {
        
        guard let structDecl = declaration.as(StructDeclSyntax.self),
              declaration.kind == SwiftSyntax.SyntaxKind.structDecl
        else { throw RouteObserveMacroError.unsupported }
        
        let structName = structDecl.name.text
        
        guard let genericParam = structDecl.genericParameterClause?.as(GenericParameterClauseSyntax.self)?.parameters.as(GenericParameterListSyntax.self),
              let genericName = genericParam.first?.as(GenericParameterSyntax.self)?.name.text,
              genericParam.count == 1, genericName == genericContent
        else { throw RouteObserveMacroError.invalidGenericFormat(structName) }
        
        guard let inheritanceClause = structDecl.inheritanceClause?.as(InheritanceClauseSyntax.self)?.inheritedTypes.as(InheritedTypeListSyntax.self),
              let inheriName = inheritanceClause.first?.as(InheritedTypeSyntax.self)?.type.as(IdentifierTypeSyntax.self)?.name.text,
              inheriName == "View"
        else { throw RouteObserveMacroError.invalidGenericFormat(structName) }
        
        
        if let genericInheri = genericParam.first?.inheritedType?.as(IdentifierTypeSyntax.self),
           genericInheri.name.text == "View" {
            return
        }
        
        guard let genericWhereClause = structDecl.genericWhereClause?.as(GenericWhereClauseSyntax.self),
              let require = genericWhereClause.requirements.as(GenericRequirementListSyntax.self)?.first?.as(GenericRequirementSyntax.self),
              let conformance = require.requirement.as(ConformanceRequirementSyntax.self),
              let leftTypeName = conformance.leftType.as(IdentifierTypeSyntax.self)?.name.text,
              let rightTypeName = conformance.rightType.as(IdentifierTypeSyntax.self)?.name.text,
              leftTypeName == genericContent && rightTypeName == "View"
        else { throw RouteObserveMacroError.invalidGenericFormat(structName) }
        
    }
}
