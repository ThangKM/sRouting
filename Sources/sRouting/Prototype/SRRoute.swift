//
//  SRRoute.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// Protocol to build ``ScreenView`` in the route.
public protocol SRRoute: Hashable, Codable {
    
    associatedtype ViewType: View
    
    var path: String { get }

    /// Screen builder
    @ViewBuilder @MainActor
    var screen: ViewType { get }
}

extension SRRoute {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.path == rhs.path
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

extension SRRoute {
    
    internal var formatedPath: String {
        path.replacingOccurrences(of: " ", with: "_")
    }
    
    public init(from decoder: any Decoder) throws {
        throw SRRoutingError.unsupportedDecodable
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(formatedPath)
        
    }
}
