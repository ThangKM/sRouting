//
//  Router.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// A screen's router that can navigate to other screen of route.
///
/// The router can trigger a transition from inside(view) or outside(view model) the view.
/// Required perfrom actions on the `MainThread`  for iOS 14 and below
open class Router<RouteType>: ObservableObject
where RouteType: Route {
    
    private(set) var transition: SRTransition<RouteType>
    
    public init() {
        transition = .none
    }
    
    /// Select tabbar item at index
    /// Required oberve selection of `TabView` from ``RootRouter``
    /// - Parameter index: Index of tabbar item
    ///
    /// ### Example
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
    ///   - action: ``SRTriggerType``
    ///
    /// ### Example
    /// ```swift
    /// router.trigger(to: .detailScreen, with: .push)
    /// ```
    open func trigger(to route: RouteType, with action: SRTriggerType) {
        transition = .init(with: route, and: .init(with: action))
        objectWillChange.send()
    }
    
    /// Show an alert
    /// - Parameters:
    ///   - error: Type of `Error`
    ///   - title: The error's title
    ///
    /// ### Example
    /// ```swift
    /// router.show(NetworkingError.notFound)
    /// ```
    open func show(error: Error, and title: String? = nil) {
        transition = .init(with: error, and: title)
        objectWillChange.send()
    }
    
    /// Show an alert
    /// - Parameter alert: Alert
    ///
    /// ### Example
    /// ```swift
    /// router.show(alert:  Alert.init(title: Text("Alert"),
    ///                                message: Text("Message"),
    ///                                dismissButton: .cancel(Text("OK")))
    /// ```
    open func show(alert: Alert) {
        transition = .init(with: alert)
        objectWillChange.send()
    }
    
    #if os(iOS) || os(tvOS)
    open func show(actionSheet: ActionSheet) {
        transition = .init(with: actionSheet)
        objectWillChange.send()
    }
    #endif
    
    /// Dismiss or pop current screen
    ///
    /// ### Example
    /// ```swift
    /// router.dismiss()
    /// ```
    open func dismiss() {
        transition = .init(with: .dismiss)
        objectWillChange.send()
    }
    
    /// Dismiss to root view
    ///
    /// ### Example
    /// ```swift
    /// router.dismissAll()
    /// ```
    open func dismissAll() {
        transition = .init(with: .dismissAll)
        objectWillChange.send()
    }
}

//MARK:- Internal Methods
extension Router {
    
    func resetTransition(scenePhase: ScenePhase) {
       guard scenePhase == .active else { return }
       transition = .none
   }
}
