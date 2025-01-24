//
//  SRRoute.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

//MARK: - SRConfirmationDialogRoute
public protocol SRConfirmationDialogRoute: Sendable {
    
    associatedtype Message: View
    associatedtype Actions: View
    
    var titleKey: LocalizedStringKey { get }
    
    var titleVisibility: Visibility { get }
    
    var stringMessage: LocalizedStringKey { get }
    
    @ViewBuilder @MainActor
    var message: Message { get }
    
    @ViewBuilder @MainActor
    var actions: Actions { get }
}

public struct ConfirmationDialogEmptyRoute: SRConfirmationDialogRoute {

    public var titleKey: LocalizedStringKey { "" }
    public var stringMessage: LocalizedStringKey { "Default Confirmation Dialog!" }
    public var message: some View { Text(stringMessage) }
    public var actions: some View { Button("OK"){ } }
    public var titleVisibility: Visibility = .hidden
}

//MARK: - SRAlertRoute
public protocol SRAlertRoute: Sendable {
    
    associatedtype Message: View
    associatedtype Actions: View
    
    var titleKey: LocalizedStringKey { get }
    
    @ViewBuilder @MainActor
    var message: Message { get }
    
    @ViewBuilder @MainActor
    var actions: Actions { get }
}

public struct AlertEmptyRoute: SRAlertRoute {
    public var titleKey: LocalizedStringKey { "Alert" }
    public var message: some View { Text("Default Alert!") }
    public var actions: some View { Button("OK"){ } }
}

//MARK: - SRRoute
/// Protocol to build screens for the route.
public protocol SRRoute: Hashable, Codable, Sendable {
    
    associatedtype Screen: View
    associatedtype AlertRoute: SRAlertRoute
    associatedtype ConfirmationDialogRoute: SRConfirmationDialogRoute

    var path: String { get }

    /// Screen builder
    @ViewBuilder @MainActor
    var screen: Screen { get }
}

extension SRRoute {
    
    /// Provide default type for the ``AlertRoute``
    public typealias AlertRoute = AlertEmptyRoute
    
    /// Provide default type for the ``ConfirmationDialogEmptyRoute``
    public typealias ConfirmationDialogRoute = ConfirmationDialogEmptyRoute

    /// Provide full path when self is a child route.
    public var fullPath: String {
        String(describing: Self.self) + "." + path
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.path == rhs.path
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

extension SRRoute {
    
    public init(from decoder: any Decoder) throws {
        throw SRRoutingError.unsupportedDecodable
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(path)
    }
}

