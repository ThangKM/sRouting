//
//  ContextMacro.swift
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

public enum ContextMacroError: Error, CustomStringConvertible {
    
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

public struct ContextMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard declaration.kind == SwiftSyntax.SyntaxKind.classDecl
                || declaration.kind == SwiftSyntax.SyntaxKind.structDecl
        else { throw RouterMacroError.unsupported }
        let arguments = try Self._arguments(of: node)
        
        var result: [DeclSyntax] = []
        
        let rootRouter: DeclSyntax = "let rootRouter = SRRootRouter()"
        result.append(rootRouter)
        
        let dsaEmiiter: DeclSyntax = "let dismissAllEmitter = SRDismissAllEmitter()"
        result.append(dsaEmiiter)
        
        let tabSelection: DeclSyntax = "let tabSelection = SRTabbarSelection()"
        result.append(tabSelection)
        
        let indexLastStack = arguments.stacks.count - 1
        var initStacks = "["
        for (index,stack) in arguments.stacks.enumerated() {
            if index == indexLastStack {
                initStacks += "SRNavStack.\(stack):SRNavigationPath()"
            } else {
                initStacks += "SRNavStack.\(stack):SRNavigationPath(), "
            }
            
        }
        initStacks += "]"

        let navStacks: DeclSyntax = "private let navStacks = \(raw: initStacks)"
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
        
        let navPathFunc: DeclSyntax = """
        @MainActor
        private func navigationPath(of stackItem: SRNavStack) -> SRNavigationPath {
            navStacks[stackItem]!
        }
        """
        result.append(navPathFunc)
        
        let singleRoutingFunc: DeclSyntax = """
        @MainActor
        private func _routing(for route: SRRootRoute) async {
            switch route {
            case .resetAll:
                dismissAllEmitter.dismissAll()
                navStacks.values.forEach({ 
                    $0.popToRoot()
                })
            case .dismissAll:
                dismissAllEmitter.dismissAll()
            case .popToRoot(of: let stack):
                navigationPath(of: stack).popToRoot()
            case .select(tabItem: let tabItem):
                tabSelection.select(tag: tabItem.rawValue)
            case .push(route: let route, into: let stack):
                let navigation = navigationPath(of: stack)
                guard navigation.didAppear else {
                   do {
                    try await Task.sleep(for: .milliseconds(200))
                   } catch {
                    print("sRouting.\\(error)")
                   }
                   navigation.push(to: route)
                   return
                }
                navigation.push(to: route)
            case .sheet(let route):
                rootRouter.trigger(to: AnyRoute(route: route), with: .sheet)
            case .window(let windowTrans):
                rootRouter.openWindow(windowTrans: windowTrans)
            case .open(let url):
                rootRouter.openURL(at: url, completion: nil)
            #if os(iOS)
            case .present(let route):
                rootRouter.trigger(to: .init(route: route), with: .present)
            #endif
            }
        }
        """
        result.append(singleRoutingFunc)
        
        let routingFunc: DeclSyntax = """
        func routing(_ routes: SRRootRoute...) async {
            let routeStream = AsyncStream { continuation in
                for route in routes {
                    continuation.yield(route)
                }
                continuation.finish()
            }

            for await route in routeStream {
                await _routing(for: route)
            }
        }
        """
        result.append(routingFunc)
        return result
    }
}

extension ContextMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        guard declaration.kind == SwiftSyntax.SyntaxKind.classDecl
                || declaration.kind == SwiftSyntax.SyntaxKind.structDecl
        else { throw RouterMacroError.unsupported }
        
        let arguments = try Self._arguments(of: node)
        
        var result: [DeclSyntax] = []
        let rootRouter: DeclSyntax = """
        @sRouter(AnyRoute.self) @Observable
        class SRRootRouter { }
        """
        result.append(rootRouter)
        
        let rootRoute: DeclSyntax =  """
        enum SRRootRoute: SRRoute {
            case resetAll
            case dismissAll
            case popToRoot(of: SRNavStack)
            case select(tabItem: SRTabItem)
            case push(route: any SRRoute, into: SRNavStack)
            case sheet(any SRRoute)
            case window(SRWindowTransition)
            case open(url: URL)
            #if os(iOS)
            case present(any SRRoute)
            #endif
        
            var screen: some View {
               fatalError("sRouting.SRContextRoute doesn't have screen")
            }
        
            var path: String {
                switch self {
                case .resetAll:
                    return "srcontext.resetall"
                case .dismissAll:
                    return "srcontext.dismissall"
                case .select:
                    return "srcontext.selecttab"
                case .push(let route,_):
                    return "srcontext.push.\\(route.path)"
                case .sheet(let route): return "srcontext.sheet.\\(route.path)"
                case .window(let transition):
                    if let id = transition.windowId {
                        return "srcontext.window.\\(id)"
                    } else if let value = transition.windowValue {
                        return "srcontext.window.\\(value.hashValue)"
                    } else {
                        return "srcontext.window"
                    }
                case .open(let url):
                    return "srcontext.openurl.\\(url.absoluteString)"
                case .popToRoot:
                    return "srcontext.popToRoot"
                #if os(iOS)
                case .present(let route):
                    return "srcontext.present.\\(route.path)"
                #endif
                }
            }
        }
        """
        result.append(rootRoute)
        
        let iheritanceClause: InheritanceClauseSyntax = .init(inheritedTypes:
                .init(arrayLiteral: InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "Int"))))
        
        let tabItem = DeclSyntax(
            EnumDeclSyntax(name: "SRTabItem", inheritanceClause:iheritanceClause) {
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
            EnumDeclSyntax(name: "SRNavStack", inheritanceClause:navIheritanceClause) {
                for stack in arguments.stacks {
                    "case \(raw: stack)"
                }
            }
        )
        result.append(navStack)
        return result
    }
}

extension ContextMacro {
    
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
                else { throw ContextMacroError.missingArguments }
                let elements = exp.elements.map(\.expression).compactMap({ $0.as(StringLiteralExprSyntax.self) })
                let contents = elements.compactMap(\.segments.first).compactMap({ $0.as(StringSegmentSyntax.self)})
                let items = contents.map(\.content.text)
                tabs.append(contentsOf: items)
            case stacksParam:
                guard let exp = labeled.expression.as(StringLiteralExprSyntax.self),
                      let segment = exp.segments.first?.as(StringSegmentSyntax.self)
                else { throw ContextMacroError.missingArguments }
                
                let input = segment.content.text
                stacks.append(input)
            default: continue
            }
        }
        
        guard !tabs.isEmpty || !stacks.isEmpty else { throw ContextMacroError.missingArguments }
        return (tabs,stacks)
    }
}

extension ContextMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let decl: DeclSyntax = """
            extension \(raw: type.trimmedDescription): sRouting.SRContextType {}
            """
        let ext = decl.cast(ExtensionDeclSyntax.self)
        
        return [ext]
    }
}