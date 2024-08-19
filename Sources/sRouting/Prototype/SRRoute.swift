//
//  SRRoute.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// Protocol to build ``ScreenView`` in the route.
public protocol SRRoute: Hashable {
    
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
