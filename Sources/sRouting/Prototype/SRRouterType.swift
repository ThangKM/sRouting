//
//  SRRouterType.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// A screen's router that can navigate to other screen of route.
///
/// The router can trigger a transition from inside(view) or outside(view model) the view.
@MainActor
public protocol SRRouterType<RouteType> where RouteType: SRRoute {

    typealias AcceptionCallback = @Sendable (_ accepted: Bool) -> Void
    typealias ErrorHandler = @Sendable (_ error: Error?) -> Void
    
    associatedtype RouteType: SRRoute
    
    var transition: SRTransition<RouteType> { get }
    
    /// Select tabbar item at index
    /// - Parameter index: Index of tabbar item
    ///
    /// ### Example
    /// ```swift
    /// router.selectTabbar(at: 0)
    /// ```
    func selectTabbar(at index: Int)
    
    /// Trigger to new screen
    /// - Parameters:
    ///   - route: Type of ``SRRouterType``
    ///   - action: ``SRTriggerType``
    ///
    /// ### Example
    /// ```swift
    /// router.trigger(to: .detailScreen, with: .push)
    /// ```
    func trigger(to route: RouteType, with action: SRTriggerType)
    
    /// Show an alert
    /// - Parameters:
    ///   - error: Type of `Error`
    ///   - title: The error's title
    ///
    /// ### Example
    /// ```swift
    /// router.show(NetworkingError.notFound)
    /// ```
    func show(error: Error, and title: String?)
    
    /// Show an alert
    /// - Parameter alert: Alert
    ///
    /// ### Example
    /// ```swift
    /// router.show(alert:  Alert.init(title: Text("Alert"),
    ///                                message: Text("Message"),
    ///                                dismissButton: .cancel(Text("OK")))
    /// ```
    func show(alert: Alert)
    
    #if os(iOS) || os(tvOS)
    func show(actionSheet: ActionSheet)
    #endif
    
    /// Dismiss or pop current screen
    ///
    /// ### Example
    /// ```swift
    /// router.dismiss()
    /// ```
    func dismiss()
    
    /// Dismiss to root view
    ///
    /// ### Example
    /// ```swift
    /// router.dismissAll()
    /// ```
    func dismissAll()
    
    /// Navigation pop
    func pop()
    
    /// Navigation pop to root
    func popToRoot()
    
    /// Navigation pop to route
    /// - Parameter route: some``SRRoute``
    func pop(to route: some SRRoute)
    
    /// Opens a window that's associated with the specified transition.
    /// - Parameter windowTrans: ``SRWindowTransition``
    ///
    /// ### Example
    /// ```swif
    /// openWindow(windowTrans: windowTrans)
    /// ```
    func openWindow(windowTrans: SRWindowTransition)
    
    /// Opens a URL, following system conventions.
    /// - Parameters:
    ///   - url: `URL`
    ///   - completion: `AcceptionCallback`
    func openURL(at url: URL, completion: AcceptionCallback?)
    
    #if os(macOS)
    /// Opens the document at the specified file URL.
    /// - Parameters:
    ///   - url: file URL
    ///   - completion: `ErrorHandler`
    func openDocument(at url: URL, completion: ErrorHandler?)
    #endif
}
