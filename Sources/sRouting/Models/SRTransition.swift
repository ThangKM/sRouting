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
    private(set) var alert: GetAlert?
    private(set) var tabIndex: Int?
    private(set) var popToRoute: (any SRRoute)?
    private(set) var windowTransition: SRWindowTransition?
    
    #if os(iOS) || os(tvOS)
    private(set) var actionSheet: GetActionSheet?
    
    init(with actionSheet: GetActionSheet?, and transaction: WithTransaction? = .none) {
        self.type = .actionSheet
        self.contextId = TimeIdentifier()
        self.actionSheet = actionSheet
        self.transaction = transaction
    }
  
    init(with type: SRTransitionKind, and transaction: WithTransaction? = .none) {
        self.type = type
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    init(selectTab index: Int, and transaction: WithTransaction? = .none) {
        self.type = .selectTab
        self.contextId = TimeIdentifier()
        self.tabIndex = index
        self.transaction = transaction
    }

    init(with alert: GetAlert?, and transaction: WithTransaction? = .none) {
        self.type = .alert
        self.contextId = TimeIdentifier()
        self.alert = alert
        self.transaction = transaction
    }
    
    init(with error: Error, and alertTitle: String? = nil, transaction: WithTransaction? = .none) {
        self.type = .alert
        self.contextId = TimeIdentifier()
        self.alert = { @Sendable in
            Alert.init(title: Text(alertTitle ?? ""),
                       message: Text(error.localizedDescription),
                       dismissButton: .cancel(Text("OK")))
        }
        self.transaction = transaction
    }
    
    init(with route: Route, and action: SRTransitionKind, transaction: WithTransaction? = .none) {
        self.type = action
        self.route = route
        self.contextId = TimeIdentifier()
        self.alert = nil
        self.transaction = transaction
    }
    
    init(popTo route: some SRRoute, and transaction: WithTransaction? = .none) {
        self.type = .popToRoute
        self.popToRoute = route
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
    #else
    init(with type: SRTransitionKind,
                windowTransition: SRWindowTransition,
                transaction: WithTransaction? = .none) {
        self.contextId = TimeIdentifier()
        self.type = type
        self.windowTransition = windowTransition
        self.transaction = transaction
    }
    
    init(with type: SRTransitionKind, and transaction: WithTransaction? = .none) {
        self.type = type
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    init(selectTab index: Int, and transaction: WithTransaction? = .none) {
        self.type = .selectTab
        self.tabIndex = index
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }

    init(with alert: GetAlert?, and transaction: WithTransaction? = .none) {
        self.type = .alert
        self.alert = alert
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    init(with error: Error, and alertTitle: String? = nil, transaction: WithTransaction? = .none) {
        self.type = .alert
        self.alert = { @Sendable in
            Alert.init(title: Text(alertTitle ?? ""),
                       message: Text(error.localizedDescription),
                       dismissButton: .cancel(Text("OK")))
        }
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    init(with route: Route, and action: SRTransitionKind, transaction: WithTransaction? = .none) {
        precondition(action != .present, "macOS didn't support fullScreenCover")
        precondition(action != .actionSheet, "macOS didn't support actionSheet")
        self.type = action
        self.route = route
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    init(popTo route: some SRRoute, and transaction: WithTransaction? = .none) {
        self.type = .popToRoute
        self.popToRoute = route
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    #endif
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
        && lhs.tabIndex == rhs.tabIndex
        && lhs.route == rhs.route
        && lhs.contextId == rhs.contextId
    }
}
