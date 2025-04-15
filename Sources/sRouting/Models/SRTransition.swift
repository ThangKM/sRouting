//
//  SRTransition.swift
//
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

public struct SRTransition<Route>: Sendable
where Route: SRRoute {
    
    let contextId: TimeIdentifier
    let type: SRTransitionKind
    
    let transaction: WithTransaction?
    private(set) var route: Route?
    private(set) var alert: Route.AlertRoute?
    private(set) var tabIndex: (any IntRawRepresentable)?
    private(set) var popToPath: (any StringRawRepresentable)?
    private(set) var windowTransition: SRWindowTransition?
    private(set) var confirmationDialog: Route.ConfirmationDialogRoute?
    private(set) var popover: Route.PopoverRoute?
    
    init(with route: Route.PopoverRoute?, and transaction: WithTransaction? = .none) {
        self.type = .popover
        self.contextId = TimeIdentifier()
        self.popover = route
        self.transaction = transaction
    }
    
    init(with route: Route.ConfirmationDialogRoute?, and transaction: WithTransaction? = .none) {
        self.type = .confirmationDialog
        self.contextId = TimeIdentifier()
        self.confirmationDialog = route
        self.transaction = transaction
    }

    init(with type: SRTransitionKind, and transaction: WithTransaction? = .none) {
        self.type = type
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    init(selectTab tab: any IntRawRepresentable, and transaction: WithTransaction? = .none) {
        self.type = .selectTab
        self.contextId = TimeIdentifier()
        self.tabIndex = tab
        self.transaction = transaction
    }

    init(with alert: Route.AlertRoute, and transaction: WithTransaction? = .none) {
        self.type = .alert
        self.contextId = TimeIdentifier()
        self.alert = alert
        self.transaction = transaction
    }
    
    init(with route: Route, and action: SRTransitionKind, transaction: WithTransaction? = .none) {
        self.type = action
        self.route = route
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    init(popTo path: some StringRawRepresentable, and transaction: WithTransaction? = .none) {
        self.type = .popToRoute
        self.popToPath = path
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    init(with type: SRTransitionKind,
                windowTransition: SRWindowTransition,
                transaction: WithTransaction? = .none) {
        self.contextId = TimeIdentifier()
        self.type = type
        self.windowTransition = windowTransition
        self.transaction = transaction
    }
}

extension SRTransition {
    public static var none: SRTransition {
        SRTransition(with: SRTransitionKind.none)
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
        && lhs.contextId == rhs.contextId
    }
}
