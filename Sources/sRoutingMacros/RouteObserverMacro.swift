//
//  RouteObserverMacro.swift
//
//
//  Created by Thang Kieu on 19/8/24.
//

import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros
import Foundation

private let genericContent = "Content"

package struct RouteObserverMacro: MemberMacro {
    
    package static func expansion(of node: AttributeSyntax,
                                  providingMembersOf declaration: some DeclGroupSyntax,
                                  conformingTo protocols: [TypeSyntax],
                                  in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        try _validateDeclaration(declaration)
        
        let routes = try Self._arguments(of: node)
        
        var destinationObserve = ""
        for route in routes {
            destinationObserve += ".navigationDestination(for: \(route).self) { route in route.screen.environment(path) }\n"
        }
        
        let decl: DeclSyntax = """
        @Environment(SRNavigationPath.self)
        private var path

        init() { }
        
        @MainActor
        func body(content: Content) -> some View {
            content
            \(raw: destinationObserve)
        }
        """
        return [decl]
    }
}

extension RouteObserverMacro: ExtensionMacro {
    
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let decl: DeclSyntax = """
            extension \(raw: type.trimmedDescription): sRouting.SRRouteObserverType {}
            """
        let ext = decl.cast(ExtensionDeclSyntax.self)
        
        return [ext]
    }
}


extension RouteObserverMacro {
    
    private static func _arguments(of node: AttributeSyntax) throws -> [String] {
        
        guard case let .argumentList(arguments) = node.arguments, !arguments.isEmpty
        else { throw SRMacroError.missingArguments }
        
        var routes = [String]()
        for labeled in arguments {
            guard let exp = labeled.expression.as(MemberAccessExprSyntax.self),
                  let base = exp.base?.as(DeclReferenceExprSyntax.self)
            else { throw SRMacroError.haveToUseMemberAccess }
            
            let declName = exp.declName.baseName
            guard declName.text == "self"
            else { throw SRMacroError.haveToUseMemberAccess }
            
            let input = base.baseName.text
            routes.append(input)
        }
        
        guard !routes.isEmpty else { throw SRMacroError.missingArguments }
        guard Set(routes).count == routes.count else { throw SRMacroError.duplication }
        
        return routes
    }
    
    private static func _validateDeclaration(_ declaration: DeclGroupSyntax) throws {
        
        guard declaration.kind == SwiftSyntax.SyntaxKind.structDecl
        else { throw SRMacroError.onlyStruct }
    }
}
