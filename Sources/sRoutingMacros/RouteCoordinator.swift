
//
//  RouteCoordinator.swift
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

package struct RouteCoordinator: MemberMacro {
    
    package static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard declaration.kind == SwiftSyntax.SyntaxKind.classDecl
                || declaration.kind == SwiftSyntax.SyntaxKind.structDecl
        else { throw SRMacroError.structOrClass }
        let arguments = try Self._arguments(of: node)
        
        var result: [DeclSyntax] = []
        
        let rootRouter: DeclSyntax = "@MainActor let rootRouter = SRRouter(AnyRoute.self)"
        result.append(rootRouter)
        
        let dsaEmiiter: DeclSyntax = "@MainActor let dismissAllEmitter = SRDismissAllEmitter()"
        result.append(dsaEmiiter)
        
        let tabSelection: DeclSyntax = "@MainActor let tabSelection = SRTabbarSelection()"
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

        let navStacks: DeclSyntax = "@MainActor private let navStacks = \(raw: initStacks)"
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
        
        let defaultInit: DeclSyntax = """
        @MainActor init() { }
        """
        result.append(defaultInit)
        
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
                    try await Task.sleep(for: .milliseconds(300))
                   } catch {
                    print("sRouting.\\(error)")
                   }
                   navigation.push(to: route)
                   try? await Task.sleep(for: .milliseconds(300))
                   return
                }
                navigation.push(to: route)
                try? await Task.sleep(for: .milliseconds(300))
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
        @MainActor
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

extension RouteCoordinator: PeerMacro {
    package static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        guard declaration.kind == SwiftSyntax.SyntaxKind.classDecl
                || declaration.kind == SwiftSyntax.SyntaxKind.structDecl
        else { throw SRMacroError.structOrClass }
        
        let arguments = try Self._arguments(of: node)
        
        var result: [DeclSyntax] = []

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
               fatalError("sRouting.SRRootRoute doesn't have screen")
            }
        
            var path: String {
                switch self {
                case .resetAll:
                    return "rootroute.resetall"
                case .dismissAll:
                    return "rootroute.dismissall"
                case .select:
                    return "rootroute.selecttab"
                case .push(let route,_):
                    return "rootroute.push.\\(route.path)"
                case .sheet(let route): return "rootroute.sheet.\\(route.path)"
                case .window(let transition):
                    if let id = transition.windowId {
                        return "rootroute.window.\\(id)"
                    } else if let value = transition.windowValue {
                        return "rootroute.window.\\(value.hashValue)"
                    } else {
                        return "rootroute.window"
                    }
                case .open(let url):
                    return "rootroute.openurl.\\(url.absoluteString)"
                case .popToRoot:
                    return "rootroute.popToRoot"
                #if os(iOS)
                case .present(let route):
                    return "rootroute.present.\\(route.path)"
                #endif
                }
            }
        }
        """
        result.append(rootRoute)
        
        let iheritanceClause: InheritanceClauseSyntax = .init(inheritedTypes:
                .init(arrayLiteral: InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "Int"), trailingTrivia: .unexpectedText(",")),
                      InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "Sendable"))))
        
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
                .init(arrayLiteral: InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "String"), trailingTrivia: .unexpectedText(",")),
                      InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "Sendable"))))
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

extension RouteCoordinator {
    
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

extension RouteCoordinator: ExtensionMacro {
    
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let decl: DeclSyntax = """
            extension \(raw: type.trimmedDescription): sRouting.SRRouteCoordinatorType {}
            """
        let ext = decl.cast(ExtensionDeclSyntax.self)
        
        return [ext]
    }
}
