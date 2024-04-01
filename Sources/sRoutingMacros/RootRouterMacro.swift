//
//  RootRouterMacro.swift
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

public enum RootRouterMacroError: Error, CustomStringConvertible {
    
    case unsupported
    case missingArguments
    
    public var description: String {
        switch self {
        case .unsupported:
            return "Support for class or struct!"
        case .missingArguments:
            return "Missing arguments!"
        }
    }
}

public struct RootRouterMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard declaration.kind == SwiftSyntax.SyntaxKind.classDecl
                || declaration.kind == SwiftSyntax.SyntaxKind.structDecl
        else { throw RouterMacroError.unsupported }
        let arguments = try Self._arguments(of: node)
        
        var result: [DeclSyntax] = []
        
        let dsaEmiiter: DeclSyntax = "let dismissAllEmitter = SRDismissAllEmitter()"
        result.append(dsaEmiiter)
        
        let haveTabar = !arguments.tabs.isEmpty
        let tabSelection: DeclSyntax = "\(raw: haveTabar ? "" : "private") let tabSelection = SRTabarSelection()"
        result.append(tabSelection)
        
        let indexLastStack = arguments.stacks.count - 1
        var initStacks = "["
        for (index,stack) in arguments.stacks.enumerated() {
            if index == indexLastStack {
                initStacks += "SRNavStacks.\(stack):SRNavigationPath()"
            } else {
                initStacks += "SRNavStacks.\(stack):SRNavigationPath(), "
            }
            
        }
        initStacks += "]"

        let navStacks: DeclSyntax = "private let navStacks = \(raw: initStacks)"
        result.append(navStacks)
        
        let navPathFunc: DeclSyntax = """
        @MainActor
        func navigationPath(of stackItem: SRNavStacks) -> SRNavigationPath {
            navStacks[stackItem]!
        }
        """
        result.append(navPathFunc)
        
        let routingFunc: DeclSyntax = """
        @MainActor
        func routing(_ routes: SRRootRoute...) {
            for route in routes {
                switch route {
                case .resetAll:
                    dismissAllEmitter.dismissAll()
                    tabSelection.select(tag: .zero)
                case .select(let item):
                    tabSelection.select(tag: item.rawValue)
                case .push(let route, let stack):
                    navigationPath(of: stack).push(to: route)
                default: break
                }
            }
        }
        """
        result.append(routingFunc)
        return result
    }
}

extension RootRouterMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        guard declaration.kind == SwiftSyntax.SyntaxKind.classDecl
                || declaration.kind == SwiftSyntax.SyntaxKind.structDecl
        else { throw RouterMacroError.unsupported }
        
        let arguments = try Self._arguments(of: node)
        
        var result: [DeclSyntax] = []
        let rootRoute: DeclSyntax =  """
            enum SRRootRoute: SRRoute {
                case resetAll
                case dismissAll
                case popToRoot
                case select(tabItem: SRTabItems)
                case push(route: any SRRoute, into: SRNavStacks)
                case sheet(any SRRoute)
                case window(SRWindowTransition)
                #if os(iOS)
                case present(any SRRoute)
                #endif
                
                var path: String {
                    switch self {
                    case .resetAll: return "srcontext.resetall"
                    case .dismissAll: return "srcontext.dismissall"
                    case .select: return "srcontext.selecttab"
                    case .push(let route,_): return "srcontext.push.\\(route.path)"
                    case .sheet(let route): return "srcontext.sheet.\\(route.path)"
                    case .window(let transition):
                        if let id = transition.windowId {
                            return "srcontext.window.\\(id)"
                        } else if let value = transition.windowValue {
                            return "srcontext.window.\\(value.hashValue)"
                        } else {
                            return "srcontext.window"
                        }
                    case .popToRoot: return "srcontext.popToRoot"
                    #if os(iOS)
                    case .present(let route): return "srcontext.present.\\(route.path)"
                    #endif
                    }
                }
                
                var screen: some View {
                   fatalError("sRouting.SRContextRoute doesn't have screen")
                }
            }
            """
        result.append(rootRoute)
        
        let iheritanceClause: InheritanceClauseSyntax = .init(inheritedTypes:
                .init(arrayLiteral: InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "Int"))))
        
        let tabItem = DeclSyntax(
            EnumDeclSyntax(name: "SRTabItems", inheritanceClause:iheritanceClause) {
                if arguments.tabs.isEmpty {
                    "case none"
                } else {
                    for item in arguments.tabs {
                        "case \(raw: item)"
                    }
                }
            }
        )
        result.append(tabItem)

        let navIheritanceClause: InheritanceClauseSyntax = .init(inheritedTypes:
                .init(arrayLiteral: InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "String"))))
        let navStack = DeclSyntax(
            EnumDeclSyntax(name: "SRNavStacks", inheritanceClause:navIheritanceClause) {
                for stack in arguments.stacks {
                    "case \(raw: stack)"
                }
            }
        )
        result.append(navStack)
        return result
    }
}

extension RootRouterMacro {
    
    private static func _arguments(of node: AttributeSyntax) throws -> (tabs: [String], stacks: [String]) {
        
        guard case let .argumentList(arguments) = node.arguments, !arguments.isEmpty
        else { throw RouterMacroError.missingArguments }

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
                else { throw RootRouterMacroError.missingArguments }
                let elements = exp.elements.map(\.expression).compactMap({ $0.as(StringLiteralExprSyntax.self) })
                let contents = elements.compactMap(\.segments.first).compactMap({ $0.as(StringSegmentSyntax.self)})
                let items = contents.map(\.content.text)
                tabs.append(contentsOf: items)
            case stacksParam:
                guard let exp = labeled.expression.as(StringLiteralExprSyntax.self),
                      let segment = exp.segments.first?.as(StringSegmentSyntax.self)
                else { throw RootRouterMacroError.missingArguments }
                
                let input = segment.content.text
                stacks.append(input)
            default: continue
            }
        }
        
        guard !tabs.isEmpty || !stacks.isEmpty else { throw RootRouterMacroError.missingArguments }
        return (tabs,stacks)
    }
}
