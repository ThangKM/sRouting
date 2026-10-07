
//
//  RouteCoordinatorMacro.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros
import Foundation

private let tabsParam = "tabs"
private let stacksParam = "stacks"

package struct RouteCoordinatorMacro: MemberMacro {
    
    package static func expansion(of node: AttributeSyntax,
                                  providingMembersOf declaration: some DeclGroupSyntax,
                                  conformingTo protocols: [TypeSyntax],
                                  in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self), declaration.kind == SwiftSyntax.SyntaxKind.classDecl
        else { throw SRMacroError.onlyClass }
        
        guard Self._isObservable(classDecl) else { throw SRMacroError.missingObservable }
        
        let className = classDecl.name.text.trimmingCharacters(in: .whitespaces)
        let arguments = try Self._arguments(of: node)
        
        var result: [DeclSyntax] = []

        result.append(DeclSyntax(try VariableDeclSyntax("let identifier: String")))

        result.append(DeclSyntax(try VariableDeclSyntax("@MainActor let rootRouter = SRRouter(AnyRoute.self)")))

        result.append(DeclSyntax(try VariableDeclSyntax("@MainActor let emitter = SRCoordinatorEmitter()")))

        let initStacks = DictionaryExprSyntax {
            for stack in arguments.stacks {
                DictionaryElementSyntax(key: ExprSyntax("SRNavStack.\(raw: stack)"),
                                        value: ExprSyntax("SRNavigationPath(coordinator: self)"))
            }
        }
        result.append(DeclSyntax(try VariableDeclSyntax("@MainActor private lazy var navStacks = \(initStacks)")))

        for stack in arguments.stacks {
            let shortPath = try VariableDeclSyntax("@MainActor\nvar \(raw: stack)Path: SRNavigationPath") {
                ExprSyntax("navStacks[SRNavStack.\(raw: stack)]!")
            }
            result.append(DeclSyntax(shortPath))
        }

        let navigationStacks = try VariableDeclSyntax("@MainActor var navigationStacks: [SRNavigationPath]") {
            ExprSyntax("navStacks.map(\\.value)")
        }
        result.append(DeclSyntax(navigationStacks))

        result.append(DeclSyntax(try VariableDeclSyntax("@MainActor private(set) var activeNavigation: SRNavigationPath?")))

        let defaultInit = try InitializerDeclSyntax("@MainActor init()") {
            ExprSyntax("self.identifier = \(literal: className) + \(literal: "_") + TimeIdentifier.now.id")
        }
        result.append(DeclSyntax(defaultInit))

        let resgisterFunction = try FunctionDeclSyntax("@MainActor\nfunc registerActiveNavigation(_ navigationPath: SRNavigationPath)") {
            ExprSyntax("activeNavigation = navigationPath")
        }
        result.append(DeclSyntax(resgisterFunction))

        return result
    }
}

extension RouteCoordinatorMacro: ExtensionMacro {
    
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self)
        else { throw SRMacroError.onlyClass }
        
        guard Self._isObservable(classDecl) else { throw SRMacroError.missingObservable }

        let arguments = try Self._arguments(of: node)

        let extCoordinator = try ExtensionDeclSyntax("extension \(type.trimmed): sRouting.SRRouteCoordinatorType") {
            try EnumDeclSyntax("enum SRTabItem: Int, IntRawRepresentable") {
                if arguments.tabs.isEmpty {
                    DeclSyntax("case none")
                } else {
                    for item in arguments.tabs {
                        DeclSyntax("case \(raw: item)")
                    }
                }
            }
            .with(\.leadingTrivia, .newlines(2))

            try EnumDeclSyntax("enum SRNavStack: String, Sendable") {
                for stack in arguments.stacks {
                    DeclSyntax("case \(raw: stack)")
                }
            }
            .with(\.leadingTrivia, .newlines(2))
        }
        return [extCoordinator]
    }
}

extension RouteCoordinatorMacro {
    
    private static func _arguments(of node: AttributeSyntax) throws -> (tabs: [String], stacks: [String]) {
        
        guard case let .argumentList(arguments) = node.arguments, !arguments.isEmpty
        else { throw SRMacroError.missingArguments }

        var tabs = [String]()
        var stacks  = [String]()
        var currentLabel = tabsParam
        for labeled in arguments {
            
            if labeled.label?.trimmedDescription == tabsParam {
                currentLabel = tabsParam
            } else if labeled.label?.trimmedDescription == stacksParam {
                currentLabel = stacksParam
            }
            
            switch currentLabel {
            case tabsParam:
                guard let exp = labeled.expression.as(ArrayExprSyntax.self)
                else { throw SRMacroError.missingArguments }
                let elements = exp.elements.map(\.expression).compactMap({ $0.as(StringLiteralExprSyntax.self) })
                let contents = elements.compactMap(\.segments.first).compactMap({ $0.as(StringSegmentSyntax.self)})
                let items = contents.map(\.content.text)
                let tabItems = items.filter({ !$0.isEmpty })
                guard !tabItems.isEmpty else { continue }
                tabs.append(contentsOf: items)
            case stacksParam:
                guard let exp = labeled.expression.as(StringLiteralExprSyntax.self),
                      let segment = exp.segments.first?.as(StringSegmentSyntax.self)
                else { throw SRMacroError.missingArguments }
                
                let input = segment.content.text
                guard !input.isEmpty else { continue }
                stacks.append(input)
            default: continue
            }
        }
        
        guard !stacks.isEmpty else { throw SRMacroError.missingArguments }
        if !tabs.isEmpty && tabs.count != Set(tabs).count {
            throw SRMacroError.duplication
        }
        guard stacks.count == Set(stacks).count else { throw SRMacroError.duplication }
        
        return (tabs,stacks)
    }
    
    private static func _isObservable(_ declaration: some DeclGroupSyntax) -> Bool {
        declaration.attributes.contains { attribute in
            guard case let .attribute(attributeSyntax) = attribute,
                  let identifier = attributeSyntax.attributeName.as(IdentifierTypeSyntax.self)
            else { return false }
            return identifier.name.text == "Observable"
        }
    }
}
