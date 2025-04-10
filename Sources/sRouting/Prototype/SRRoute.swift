//
//  SRRoute.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

//MARK: - SRPopoverRoute
public protocol SRPopoverRoute: Sendable, Equatable {
    
    associatedtype Content: View
    
    var identifier: String { get }
    var attachmentAnchor: PopoverAttachmentAnchor { get }
    var arrowEdge: Edge? { get }
    
    @ViewBuilder @MainActor
    var content: Content { get }
}

extension SRPopoverRoute {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension SRPopoverRoute {
    
    public var attachmentAnchor: PopoverAttachmentAnchor { .rect(.bounds) }
    public var arrowEdge: Edge? { .none }
}

public struct PopoverEmptyRoute: SRPopoverRoute {
    public var identifier: String { "default popover route" }
    public var content: some View { Text("Defualt Popover") }
}

//MARK: - SRConfirmationDialogRoute
public protocol SRConfirmationDialogRoute: Sendable, Equatable {
    
    associatedtype Message: View
    associatedtype Actions: View
    
    var titleKey: LocalizedStringKey { get }
    
    var titleVisibility: Visibility { get }
    
    var identifier: String { get }
    
    @ViewBuilder @MainActor
    var message: Message { get }
    
    @ViewBuilder @MainActor
    var actions: Actions { get }
}

extension SRConfirmationDialogRoute {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

public struct ConfirmationDialogEmptyRoute: SRConfirmationDialogRoute {

    public var titleKey: LocalizedStringKey { "" }
    public var identifier: String { "Default Confirmation Dialog!" }
    public var message: some View { Text(identifier) }
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
    associatedtype PopoverRoute: SRPopoverRoute
    
    var path: String { get }

    /// Screen builder
    @ViewBuilder @MainActor
    var screen: Screen { get }
}

extension SRRoute {
    
    /// Provide default type for the ``SRAlertRoute``
    public typealias AlertRoute = AlertEmptyRoute
    
    /// Provide default type for the ``SRConfirmationDialogRoute``
    public typealias ConfirmationDialogRoute = ConfirmationDialogEmptyRoute

    /// Provide default type for the ``SRPopoverRoute``
    public typealias PopoverRoute = PopoverEmptyRoute
    
    public var transaction: SwiftUI.Transaction? { .none }
    
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

