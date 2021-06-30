//
//  Route.swift
//  sRouting
//
//  Created by ThangKieu on 2/10/21.
//

import SwiftUI

public protocol Route {
    
    associatedtype ViewType: View
    
    @ViewBuilder
    var screen: ViewType { get }
    
    var alert: Alert? { get }
}

extension Route {
    public var alert: Alert? { return nil }
}
