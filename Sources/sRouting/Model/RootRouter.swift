//
//  RootRouter.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// Manage  states and actions on `Root`.
/// Required inject into EnviromentObject on root view.
///
/// Provide selection state of  root tabbar view.
///  ```swift
/// TabView(selection: $rootRouter.tabbarSelection) {
///     ...
/// }
///  ```
///  Provide `dismiss` to root action.
///  ```swift
///  screenRouter.dismissAll()
///  ```
@MainActor
open class RootRouter: ObservableObject {
    
    /// `TabView` selection state
    @Published
    public var tabbarSelection: Int = 0
    
    ///  Dismiss to root `Published`
    @Published
    private(set) var dismissAll: UInt = 0
    
    internal func dismissToRoot() {
        dismissAll += 1
    }
}
