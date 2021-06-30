//
//  Route.swift
//  Sequence
//
//  Created by ThangKieu on 2/10/21.
//

import SwiftUI

@available(iOS 13.0, *)
public protocol Route {
    
    associatedtype ViewType: View
    
    @ViewBuilder
    var screen: ViewType { get }
    
    var alert: Alert? { get }
}

@available(iOS 13.0, *)
extension Route {
    public var alert: Alert? { return nil }
}
