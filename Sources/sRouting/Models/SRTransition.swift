//
//  SRTransition.swift
//
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

public struct SRTransition<Route>: Sendable
where Route: SRRoute {

    /// A transition and the payload it carries. Each case holds exactly what it needs.
    enum Action: Sendable {
        case none
        case dismiss
        case dismissAll
        case dismissCoordinator
        case pop
        case popToRoot
        case push(Route)
        case present(Route)
        case sheet(Route)
        case alert(Route.AlertRoute)
        case confirmationDialog(Route.ConfirmationDialogRoute)
        case popover(Route.PopoverRoute)
        case selectTab(any IntRawRepresentable)
        case popToRoute(any StringRawRepresentable)
        case openWindow(SRWindowTransition)
        case switchRoot(any SRRoute)
        case openCoordinator(CoordinatorRoute)
    }

    let transitionId: TimeIdentifier = .now
    let action: Action
    let transaction: WithTransaction?

    init(with action: Action, and transaction: WithTransaction? = .none) {
        self.action = action
        self.transaction = transaction
    }

    init(coordinator: CoordinatorRoute) {
        self.init(with: .openCoordinator(coordinator))
    }

    init(switchTo route: some SRRoute, and transaction: WithTransaction? = .none) {
        self.init(with: .switchRoot(route), and: transaction)
    }

    init(with route: Route.PopoverRoute, and transaction: WithTransaction? = .none) {
        self.init(with: .popover(route), and: transaction)
    }

    init(with route: Route.ConfirmationDialogRoute, and transaction: WithTransaction? = .none) {
        self.init(with: .confirmationDialog(route), and: transaction)
    }

    init(selectTab tab: any IntRawRepresentable, and transaction: WithTransaction? = .none) {
        self.init(with: .selectTab(tab), and: transaction)
    }

    init(with alert: Route.AlertRoute, and transaction: WithTransaction? = .none) {
        self.init(with: .alert(alert), and: transaction)
    }

    init(with route: Route, and trigger: SRTriggerType, transaction: WithTransaction? = .none) {
        switch trigger {
        case .push: self.init(with: .push(route), and: transaction)
        case .sheet: self.init(with: .sheet(route), and: transaction)
        #if os(iOS) || os(tvOS)
        case .present: self.init(with: .present(route), and: transaction)
        #endif
        }
    }

    init(popTo path: some StringRawRepresentable, and transaction: WithTransaction? = .none) {
        self.init(with: .popToRoute(path), and: transaction)
    }

    init(windowTransition: SRWindowTransition, transaction: WithTransaction? = .none) {
        self.init(with: .openWindow(windowTransition), and: transaction)
    }
}

//MARK: - Payload accessors
extension SRTransition {

    var type: SRTransitionKind {
        switch action {
        case .none: .none
        case .dismiss: .dismiss
        case .dismissAll: .dismissAll
        case .dismissCoordinator: .dismissCoordinator
        case .pop: .pop
        case .popToRoot: .popToRoot
        case .push: .push
        case .present: .present
        case .sheet: .sheet
        case .alert: .alert
        case .confirmationDialog: .confirmationDialog
        case .popover: .popover
        case .selectTab: .selectTab
        case .popToRoute: .popToRoute
        case .openWindow: .openWindow
        case .switchRoot: .switchRoot
        case .openCoordinator: .openCoordinator
        }
    }

    var route: Route? {
        switch action {
        case .push(let route), .present(let route), .sheet(let route): route
        default: nil
        }
    }

    var alert: Route.AlertRoute? {
        guard case .alert(let alert) = action else { return nil }
        return alert
    }

    var confirmationDialog: Route.ConfirmationDialogRoute? {
        guard case .confirmationDialog(let dialog) = action else { return nil }
        return dialog
    }

    var popover: Route.PopoverRoute? {
        guard case .popover(let popover) = action else { return nil }
        return popover
    }

    var tabIndex: (any IntRawRepresentable)? {
        guard case .selectTab(let tab) = action else { return nil }
        return tab
    }

    var popToPath: (any StringRawRepresentable)? {
        guard case .popToRoute(let path) = action else { return nil }
        return path
    }
}

extension SRTransition {
    public static var none: SRTransition {
        SRTransition(with: Action.none)
    }
}

extension SRTransition: Equatable {
    /// Conform Equatable
    /// - Parameters:
    ///   - lhs: left value
    ///   - rhs: right value
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.type == .none && rhs.type == .none {
            return true
        }
        return lhs.type == rhs.type
        && lhs.tabIndex?.intValue == rhs.tabIndex?.intValue
        && lhs.route == rhs.route
        && lhs.transitionId == rhs.transitionId
    }
}
