//
//  SRRouter.swift
//  sRouting
//
//  Created by Thang Kieu on 1/11/24.
//

import SwiftUI

@Observable @MainActor
public final class SRRouter<Route> where Route: SRRoute {
    
    public typealias AcceptionCallback = @Sendable (_ accepted: Bool) -> Void
    public typealias ErrorHandler = @Sendable (_ error: Error?) -> Void
    
    @ObservationIgnored
    private var _transition: SRTransition<Route> = .none

    private(set) var transition: SRTransition<Route> {
        get {
          access(keyPath: \.transition)
          return _transition
        }
        set {
          withMutation(keyPath: \.transition) {
            _transition  = newValue
          }
        }
    }
    
    public init(_ route: Route.Type) { }
    
    /// Select tabbar item at index
    /// - Parameter index: Index of tabbar item
    ///
    /// ### Example
    /// ```swift
    /// router.selectTabbar(at: 0)
    /// ```
    public func selectTabbar(at index: Int, with transaction: WithTransaction? = .none) {
        transition = .init(selectTab: index, and: transaction)
    }
    
    /// Trigger to new screen
    /// - Parameters:
    ///   - route: Type of ``SRRoute``
    ///   - action: ``SRTriggerType``
    ///
    /// ### Example
    /// ```swift
    /// router.trigger(to: .detailScreen, with: .push)
    /// ```
    public func trigger(to route: Route, with action: SRTriggerType, and transaction: WithTransaction? = .none) {
        transition = .init(with: route, and: .init(with: action), transaction: transaction)
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
    public func show(error: Error, and title: String? = nil) {
        transition = .init(with: error, and: title)
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
    public func show(alert: Alert) {
        transition = .init(with: alert)
    }
    
    #if os(iOS) || os(tvOS)
    public func show(actionSheet: ActionSheet) {
        transition = .init(with: actionSheet)
    }
    #endif
    
    /// Dismiss or pop current screen
    ///
    /// ### Example
    /// ```swift
    /// router.dismiss()
    /// ```
    public func dismiss() {
        transition = .init(with: .dismiss)
    }
    
    /// Dismiss to root view
    ///
    /// ### Example
    /// ```swift
    /// router.dismissAll()
    /// ```
    public func dismissAll() {
        transition = .init(with: .dismissAll)
    }
    
    /// Navigation pop action.
    /// - Parameter transaction: `Transaction`
    public func pop(with transaction: WithTransaction? = .none) {
        transition = .init(with: .pop, and: transaction)
    }
    
    /// Navigation pop to root action.
    /// - Parameter transaction: `Transaction`
    public func popToRoot(with transaction: WithTransaction? = .none) {
        transition = .init(with: .popToRoot, and: transaction)
    }
    
    /// Navigation pop to target action.
    /// - Parameters:
    ///   - route: ``SRRoute``
    ///   - transaction: `Transaction`
    public func pop(to route: some SRRoute, with transaction: WithTransaction? = .none) {
        transition = .init(popTo: route, and: transaction)
    }
    
    /// Opens a window that's associated with the specified transition.
    /// - Parameter windowTrans: ``SRWindowTransition``
    ///
    /// ### Example
    /// ```swif
    /// openWindow(windowTrans: windowTrans)
    /// ```
    public func openWindow(windowTrans: SRWindowTransition) {
        transition = .init(with: .openWindow, windowTransition: windowTrans)
    }
    
    /// Opens a URL, following system conventions.
    /// - Parameters:
    ///   - url: `URL`
    ///   - completion: `AcceptionCallback`
    public func openURL(at url: URL, completion: AcceptionCallback?) {
        transition = .init(with: .openURL, windowTransition: .init(url: url, acceoption: completion))
    }
    
    #if os(macOS)
    /// Opens the document at the specified file URL.
    /// - Parameters:
    ///   - url: file URL
    ///   - completion: `ErrorHandler`
    public func openDocument(at url: URL, completion: ErrorHandler?) {
        transition = .init(with: .openDocument, windowTransition: .init(url: url, errorHandler: completion))
    }
    #endif
}
