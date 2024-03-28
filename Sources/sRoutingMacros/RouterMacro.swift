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

public enum RouterMacroError: Error, CustomStringConvertible {
    
    case unsupported
    case missingArguments
    case invalidRouteType
    case missingObservable
    
    public var description: String {
        switch self {
        case .unsupported:
            return "Only support for class!"
        case .missingArguments:
            return "Missing arguments!"
        case .invalidRouteType:
            return "Requires route type conform to SRRoute!"
        case .missingObservable:
            return "Missing @Observable marco!"
        }
    }
}


public struct RouterMacro: MemberMacro {
    
    
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self),
              declaration.kind == SwiftSyntax.SyntaxKind.classDecl
        else { throw RouterMacroError.unsupported }
        
        guard case let .argumentList(arguments) = node.arguments,
              let firstElement = arguments.first?.expression
        else { throw RouterMacroError.missingArguments }
        
        guard let memberAccess = firstElement.as(MemberAccessExprSyntax.self)
        else { throw RouterMacroError.missingArguments }
        
        guard let routeType = memberAccess.base?.as(DeclReferenceExprSyntax.self)?.baseName.trimmedDescription
        else { throw RouterMacroError.invalidRouteType }
        
        let attributes = classDecl.attributes.compactMap({ $0.as(AttributeSyntax.self) })
        guard attributes.first(where: { $0.attributeName.trimmedDescription == "Observable" }) != .none
        else { throw RouterMacroError.missingObservable }
        
        return ["""
        
        @MainActor
        private(set) var transition: SRTransition<\(raw: routeType)> {
            @storageRestrictions(initializes: _transition)
            init(initialValue) {
                _transition  = initialValue
            }
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
        
        @MainActor
        private var _transition: SRTransition<\(raw: routeType)> = .none
        
        /// Select tabbar item at index
        /// Required oberve selection of `TabView` from ``RootRouter``
        /// - Parameter index: Index of tabbar item
        ///
        /// ### Example
        /// ```swift
        /// router.selectTabbar(at: 0)
        /// ```
        @MainActor
        open func selectTabbar(at index: Int) {
            transition = .init(selectTab: index)
        }
        
        /// Trigger to new screen
        /// - Parameters:
        ///   - route: Type of ``Route``
        ///   - action: ``SRTriggerType``
        ///
        /// ### Example
        /// ```swift
        /// router.trigger(to: .detailScreen, with: .push)
        /// ```
        @MainActor
        open func trigger(to route: \(raw: routeType), with action: SRTriggerType) {
            transition = .init(with: route, and: .init(with: action))
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
        open func show(error: Error, and title: String? = nil) {
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
        open func show(alert: Alert) {
            transition = .init(with: alert)
        }
        
        #if os(iOS) || os(tvOS)
        @MainActor
        open func show(actionSheet: ActionSheet) {
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
        open func dismiss() {
            transition = .init(with: .dismiss)
        }
        
        /// Dismiss to root view
        ///
        /// ### Example
        /// ```swift
        /// router.dismissAll()
        /// ```
        @MainActor
        open func dismissAll() {
            transition = .init(with: .dismissAll)
        }
        
        @MainActor
        func pop() {
            transition = .init(with: .pop)
        }
        
        @MainActor
        func popToRoot() {
            transition = .init(with: .popToRoot)
        }
        
        @MainActor
        func pop(to route: some SRRoute) {
            transition = .init(popTo: route)
        }
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
