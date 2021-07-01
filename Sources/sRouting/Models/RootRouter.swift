//
//  RootRouter.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// Manage  states and actions on `Root`.
///
/// Inject into EnvironmentObject into ``RootView`` automatically.
/// Can be inherited to provide more states or actions that you need.
@MainActor
open class RootRouter: ObservableObject {
    
    /// `TabView` selection state
    ///
    /// ### Example
    /// ```swift
    /// TabView(selection: $rootRouter.tabbarSelection) {
    ///     ...
    /// }
    ///  ```
    @Published
    public var tabbarSelection: Int
    
    ///  Dismiss to root `Published`
    @Published
    private(set) var dismissAll: UInt
    
    /// Initializer
    public init() {
        tabbarSelection = 0
        dismissAll = 0
    }
    
    internal func dismissToRoot() {
        dismissAll += 1
    }
}
