//
//  SRRoute.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI


public protocol SRAlertRoute: Sendable {
    
    associatedtype Message: View
    associatedtype Actions: View
    
    var title: LocalizedStringKey { get }
    
    @ViewBuilder
    var message: Message { get }
    
    @ViewBuilder
    var actions: Actions { get }
}

public struct AlertEmptyRoute: SRAlertRoute {
    public var title: LocalizedStringKey { "" }
    public var message: some View { EmptyView() }
    public var actions: some View { EmptyView() }
}

//MARK: - SRRoute
/// Protocol to build screens for the route.
public protocol SRRoute: Hashable, Codable, Sendable {
    
    associatedtype Screen: View
    associatedtype AlertRoute: SRAlertRoute
    
    var path: String { get }

    /// Screen builder
    @ViewBuilder @MainActor
    var screen: Screen { get }
}

extension SRRoute {
    
    /// Provide default type for the AlertRoute
    public typealias AlertRoute = AlertEmptyRoute
    
    /// Provide full path when self is a child route.
    public var fullPath: String {
        String(describing: Self.self) + "." + path
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.path == rhs.path
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

