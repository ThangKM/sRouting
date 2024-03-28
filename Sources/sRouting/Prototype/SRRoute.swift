//
//  SRRoute.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// Protocol to build ``ScreenView`` in the route.
public protocol SRRoute: Equatable {
    
    associatedtype ViewType: View
    
    var path: String { get }

    /// Screen builder
    @ViewBuilder 
    var screen: ViewType { get }
}

extension SRRoute {
    
    public var title: String { "" }
}

extension SRRoute {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.path == rhs.path
    }
}
