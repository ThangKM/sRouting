
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
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self), declaration.kind == SwiftSyntax.SyntaxKind.classDecl
        else { throw SRMacroError.onlyClass }
        
        let className = classDecl.name.text.trimmingCharacters(in: .whitespaces)
        let arguments = try Self._arguments(of: node)
        
        var result: [DeclSyntax] = []
        
        let identifier: DeclSyntax = "let identifier: String"
        result.append(identifier)
        
        let rootRouter: DeclSyntax = "@MainActor let rootRouter = SRRouter(AnyRoute.self)"
        result.append(rootRouter)
        
        let dsaEmiiter: DeclSyntax = "@MainActor let emitter = SRCoordinatorEmitter()"
        result.append(dsaEmiiter)
        
        let indexLastStack = arguments.stacks.count - 1
        var initStacks = "["
        for (index,stack) in arguments.stacks.enumerated() {
            if index == indexLastStack {
                initStacks += "SRNavStack.\(stack):SRNavigationPath(coordinator: self)"
            } else {
                initStacks += "SRNavStack.\(stack):SRNavigationPath(coordinator: self), "
            }
            
        }
        initStacks += "]"

        let navStacks: DeclSyntax = "@MainActor private lazy var navStacks = \(raw: initStacks)"
        result.append(navStacks)
        
        for stack in arguments.stacks {
            let shortPath: DeclSyntax = """
            @MainActor
            var \(raw: stack)Path: SRNavigationPath {
                navStacks[SRNavStack.\(raw:stack)]!
            }
            """
            result.append(shortPath)
        }
        
        let navigationStacks: DeclSyntax = "@MainActor var navigationStacks: [SRNavigationPath] { navStacks.map(\\.value) }"
        result.append(navigationStacks)
        
        let activeNavigaiton: DeclSyntax = "@MainActor private(set) var activeNavigation: SRNavigationPath?"
        result.append(activeNavigaiton)
        
        let defaultInit: DeclSyntax = """
        @MainActor init() {
            self.identifier = \"\(raw: className)\" + \"_\" + UUID().uuidString
        }
        """
        result.append(defaultInit)
        
        let resgisterFunction: DeclSyntax = """
        @MainActor
        func registerActiveNavigation(_ navigationPath: SRNavigationPath) {
            activeNavigation = navigationPath
        }
        """
        result.append(resgisterFunction)
        
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
        
        guard declaration.kind == SwiftSyntax.SyntaxKind.classDecl
        else { throw SRMacroError.onlyClass }

        let arguments = try Self._arguments(of: node)

        var caseTabItems = ""
        if arguments.tabs.isEmpty {
            caseTabItems = "case none"
        } else {
            for item in arguments.tabs {
                caseTabItems += "case \(item)"
                if item != arguments.tabs.last {
                    caseTabItems += "\n"
                }
            }
        }
        
        var caseStackItems = ""
        for stack in arguments.stacks {
            caseStackItems += "case \(stack)"
            if stack != arguments.stacks.last {
                caseStackItems += "\n"
            }
        }
        
        let declCoordinator: DeclSyntax = """
            extension \(raw: type.trimmedDescription): sRouting.SRRouteCoordinatorType {
                
                enum SRTabItem: Int, IntRawRepresentable {
                    \(raw: caseTabItems)
                }
            
                enum SRNavStack: String, Sendable {
                    \(raw: caseStackItems)
                }
            }
            """
        let extCoordinator = declCoordinator.cast(ExtensionDeclSyntax.self)
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
}
