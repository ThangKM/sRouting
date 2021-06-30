//
//  RootRouter.swift
//  sRouting
//
//  Created by ThangKieu on 6/28/21.
//

import SwiftUI

/// Manage  actions on `Root`
@MainActor
open class RootRouter: ObservableObject {
    
    @Published
    public var tabbarSelection: Int = 0
    
    @Published
    private(set) var dismissAll: UInt = 0
    
    internal func dismissToRoot() {
        dismissAll += 1
    }
}
