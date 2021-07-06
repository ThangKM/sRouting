//
//  Route.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// Protocol to build ``ScreenView`` in the route.
public protocol Route {
    
    associatedtype ViewType: View
    
    /// Screen builder
    @ViewBuilder
    var screen: ViewType { get }
}
