//
//  RouterMacro.swift
//
//
//  Created by Thang Kieu on 18/03/2024.
//

import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros
import Foundation

public struct RouterMacro: MemberMacro {
    
    
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self),
              declaration.kind == SwiftSyntax.SyntaxKind.classDecl
        else { throw SRMacroError.onlyClass }
        
        guard case let .argumentList(arguments) = node.arguments,
              let firstElement = arguments.first?.expression
        else { throw SRMacroError.missingArguments }
        
        guard let memberAccess = firstElement.as(MemberAccessExprSyntax.self)
        else { throw SRMacroError.invalidRouteType }
        
        guard let routeType = memberAccess.base?.as(DeclReferenceExprSyntax.self)?.baseName.trimmedDescription
        else { throw SRMacroError.invalidRouteType }
        
        let attributes = classDecl.attributes.compactMap({ $0.as(AttributeSyntax.self) })
        guard attributes.first(where: { $0.attributeName.trimmedDescription == "Observable" }) != .none
        else { throw SRMacroError.missingObservable }
        
        return ["""
        
        @ObservationIgnored @MainActor
        private var _transition: SRTransition<\(raw: routeType)> = .none
        
        @MainActor
        private(set) var transition: SRTransition<\(raw: routeType)> {
            get {
              access(keyPath: \\.transition)
              return _transition
            }
            set {
              withMutation(keyPath: \\.transition) {
                _transition  = newValue
              }
            }
        }
        
        @MainActor init() { }
        
        /// Select tabbar item at index
        /// - Parameter index: Index of tabbar item
        ///
        /// ### Example
        /// ```swift
        /// router.selectTabbar(at: 0)
        /// ```
        @MainActor
        func selectTabbar(at index: Int, with transaction: WithTransaction? = .none) {
            transition = .init(selectTab: index, and: transaction)
        }
        
        /// Trigger to new screen
        /// - Parameters:
        ///   - route: Type of ``SRRoute``
        ///   - action: ``SRTriggerType``
        ///
        /// ### Example
        /// ```swift
        /// router.trigger(to: .detailScreen, with: .push)
        /// ```
        @MainActor
        func trigger(to route: \(raw: routeType), with action: SRTriggerType, and transaction: WithTransaction? = .none) {
            transition = .init(with: route, and: .init(with: action), transaction: transaction)
        }
        
        /// Show an alert
        /// - Parameters:
        ///   - error: Type of `Error`
        ///   - title: The error's title
        ///
        /// ### Example
        /// ```swift
        /// router.show(NetworkingError.notFound)
        /// ```
        @MainActor
        func show(error: Error, and title: String? = nil) {
            transition = .init(with: error, and: title)
        }
        
        /// Show an alert
        /// - Parameter alert: Alert
        ///
        /// ### Example
        /// ```swift
        /// router.show(alert:  Alert.init(title: Text("Alert"),
        ///                                message: Text("Message"),
        ///                                dismissButton: .cancel(Text("OK")))
        /// ```
        @MainActor
        func show(alert: Alert) {
            transition = .init(with: alert)
        }
        
        #if os(iOS) || os(tvOS)
        @MainActor
        func show(actionSheet: ActionSheet) {
            transition = .init(with: actionSheet)
        }
        #endif
        
        /// Dismiss or pop current screen
        ///
        /// ### Example
        /// ```swift
        /// router.dismiss()
        /// ```
        @MainActor
        func dismiss() {
            transition = .init(with: .dismiss)
        }
        
        /// Dismiss to root view
        ///
        /// ### Example
        /// ```swift
        /// router.dismissAll()
        /// ```
        @MainActor
        func dismissAll() {
            transition = .init(with: .dismissAll)
        }
        
        @MainActor
        func pop(with transaction: WithTransaction? = .none) {
            transition = .init(with: .pop, and: transaction)
        }
        
        @MainActor
        func popToRoot(with transaction: WithTransaction? = .none) {
            transition = .init(with: .popToRoot, and: transaction)
        }
        
        @MainActor
        func pop(to route: some SRRoute, with transaction: WithTransaction? = .none) {
            transition = .init(popTo: route, and: transaction)
        }
        
        /// Opens a window that's associated with the specified transition.
        /// - Parameter windowTrans: ``SRWindowTransition``
        ///
        /// ### Example
        /// ```swif
        /// openWindow(windowTrans: windowTrans)
        /// ```
        @MainActor
        func openWindow(windowTrans: SRWindowTransition) {
            transition = .init(with: .openWindow, windowTransition: windowTrans)
        }
        
        /// Opens a URL, following system conventions.
        /// - Parameters:
        ///   - url: `URL`
        ///   - completion: `AcceptionCallback`
        @MainActor
        func openURL(at url: URL, completion: AcceptionCallback?) {
            transition = .init(with: .openURL, windowTransition: .init(url: url, acceoption: completion))
        }
        
        #if os(macOS)
        /// Opens the document at the specified file URL.
        /// - Parameters:
        ///   - url: file URL
        ///   - completion: `ErrorHandler`
        @MainActor
        func openDocument(at url: URL, completion: ErrorHandler?) {
            transition = .init(with: .openDocument, windowTransition: .init(url: url, errorHandler: completion))
        }
        #endif
        """]
    }
}

extension RouterMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let decl: DeclSyntax = """
            extension \(raw: type.trimmedDescription): sRouting.SRRouterType {}
            """
        let ext = decl.cast(ExtensionDeclSyntax.self)
        
        return [ext]
    }
}
