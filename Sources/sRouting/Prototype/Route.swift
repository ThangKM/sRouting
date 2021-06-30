//
//  Route.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// Protocol to define ``ScreenView`` in the route.
public protocol Route {
    
    associatedtype ViewType: View
    
    /// Screen builder
    @ViewBuilder
    var screen: ViewType { get }
    
    /// Alert builder
    @ViewBuilder
    var alert: Alert? { get }
}

extension Route {
    public var alert: Alert? { return nil }
}
