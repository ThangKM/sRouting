//
//  Router.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// A screen's router that can navigate to other screens of route.
///
/// The router can trigger a transition from inside(view) or outside(view model) the view.
/// Required perfrom actions on the `MainThread`  for iOS 14 and below
@MainActor
open class Router<RouteType>: ObservableObject
where RouteType: Route {
    
    private(set) var transition: Transition<RouteType> = .none
    
    internal func resetTransition(scenePhase: ScenePhase) {
        guard scenePhase == .active else { return }
        transition = .none
    }
    
    /// Select tabbar item at index
    /// Required oberve selection of `TabView` from ``RootRouter``
    /// - Parameter index: Index of tabbar item
    ///
    ///
    /// ```swift
    /// router.selectTabbar(at: 0)
    /// ```
    open func selectTabbar(at index: Int) {
        transition = .init(selectTab: index)
        objectWillChange.send()
    }
    
    /// Trigger to new screen
    /// - Parameters:
    ///   - route: Type of ``Route``
    ///   - action: ``TriggerType``
    ///
    /// ```swift
    /// router.trigger(to: .detailScreen, with: .push)
    /// ```
    open func trigger(to route: RouteType, with action: TriggerType) {
        transition = .init(with: route, and: .init(with: action))
        objectWillChange.send()
    }
    
    /// Show a error alert
    /// - Parameters:
    ///   - error: Type of `Error`
    ///   - title: The error's title
    /// ```swift
    /// router.show(NetworkingError.notFound)
    /// ```
    open func show(error: Error, and title: String? = nil) {
        transition = .init(with: error, and: title)
        objectWillChange.send()
    }
    
    /// Dismiss or pop current screen
    /// ```swift
    /// router.dismiss()
    /// ```
    open func dismiss() {
        transition = .init(with: .dismiss)
        objectWillChange.send()
    }
    
    /// Dismiss to root view
    /// ```swift
    /// router.dismissAll()
    /// ```
    open func dismissAll() {
        transition = .init(with: .dismissAll)
        objectWillChange.send()
    }
}
