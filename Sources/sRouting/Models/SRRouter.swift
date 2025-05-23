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
    
    private(set) var transition: SRTransition<Route> = .none
    
    public init(_ route: Route.Type) { }
    
    
    /// Open a new coordinator
    /// - Parameter route: the coordinator route
    public func openCoordinator(route: some SRRoute, with action: SRTriggerType) {
        transition = .init(coordinator: .init(route:route, triggerKind: action))
    }
    
    /// Switch root to route
    /// - Parameter route: Root route
    public func switchTo(route: some SRRoute) {
        transition = .init(switchTo: route)
    }
    
    /// Show confirmation dialog
    /// - Parameter dialog: ``SRConfirmationDialogRoute``
    public func show(dialog: Route.ConfirmationDialogRoute) {
        transition = .init(with: dialog)
    }
    
    /// Show popover
    /// - Parameter dialog: ``SRPopoverRoute``
    public func show(popover: Route.PopoverRoute) {
        transition = .init(with: popover)
    }
    
    /// Select tabbar item at index
    /// - Parameter index: Index of tabbar item
    ///
    /// ### Example
    /// ```swift
    /// router.selectTabbar(at: 0)
    /// ```
    public func selectTabbar(at tab: any IntRawRepresentable, with transaction: WithTransaction? = .none) {
        transition = .init(selectTab: tab, and: transaction)
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
    /// - Parameter alert: Alert
    ///
    /// ### Example
    /// ```swift
    /// router.show(alert:  AppAlertErrors.lossConnection)
    /// ```
    public func show(alert: Route.AlertRoute, withTransaction transaction: WithTransaction? = .none) {
        transition = .init(with: alert, and: transaction)
    }
    
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
    
    /// Dismiss the presenting coordinator
    public func dismissCoordinator() {
        transition = .init(with: .dismissCoordinator)
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
    ///   - path: ``SRRoute.PathsType``
    ///   - transaction: `Transaction`
    public func pop(to path: some StringRawRepresentable, with transaction: WithTransaction? = .none) {
        transition = .init(popTo: path, and: transaction)
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
    
    /// Reset the transition to release anything the route holds.
    internal func resetTransition() {
        guard transition != .none else { return }
        transition = .none
    }
}
