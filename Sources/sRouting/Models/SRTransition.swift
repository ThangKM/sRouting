//
//  SRTransition.swift
//
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI


public struct SRTransition<RouteType>: Sendable
where RouteType: SRRoute {
    

    
    let contextId: TimeIdentifier
    let type: SRTransitionType
    let transaction: WithTransaction?
    
    private(set) var route: RouteType?
    private(set) var alert: UncheckedSendable<Alert>?
    private(set) var tabIndex: Int?
    private(set) var popToRoute: (any SRRoute)?
    private(set) var windowTransition: SRWindowTransition?
    
    #if os(iOS) || os(tvOS)
    private(set) var actionSheet: UncheckedSendable<ActionSheet>?
    
    public init(with actionSheet: ActionSheet, and transaction: WithTransaction? = .none) {
        self.type = .actionSheet
        self.contextId = TimeIdentifier()
        self.actionSheet = .init(value: actionSheet)
        self.transaction = transaction
    }
  
    public init(with type: SRTransitionType, and transaction: WithTransaction? = .none) {
        self.type = type
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    public init(selectTab index: Int, and transaction: WithTransaction? = .none) {
        self.type = .selectTab
        self.contextId = TimeIdentifier()
        self.tabIndex = index
        self.transaction = transaction
    }

    public init(with alert: Alert, and transaction: WithTransaction? = .none) {
        self.type = .alert
        self.contextId = TimeIdentifier()
        self.alert = .init(value: alert)
        self.transaction = transaction
    }
    
    public init(with error: Error, and alertTitle: String? = nil, transaction: WithTransaction? = .none) {
        self.type = .alert
        self.contextId = TimeIdentifier()
        self.alert = .init(value: SRTransition.alert(from: error, with: alertTitle))
        self.transaction = transaction
    }
    
    public init(with route: RouteType, and action: SRTransitionType, transaction: WithTransaction? = .none) {
        self.type = action
        self.route = route
        self.contextId = TimeIdentifier()
        self.alert = nil
        self.transaction = transaction
    }
    
    public init(popTo route: some SRRoute, and transaction: WithTransaction? = .none) {
        self.type = .popToRoute
        self.popToRoute = route
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    public init(with type: SRTransitionType,
                windowTransition: SRWindowTransition,
                transaction: WithTransaction? = .none) {
        self.contextId = TimeIdentifier()
        self.type = type
        self.windowTransition = windowTransition
        self.transaction = transaction
    }
    #else
    public init(with type: SRTransitionType,
                windowTransition: SRWindowTransition,
                transaction: WithTransaction? = .none) {
        self.contextId = TimeIdentifier()
        self.type = type
        self.windowTransition = windowTransition
        self.transaction = transaction
    }
    
    public init(with type: SRTransitionType, and transaction: WithTransaction? = .none) {
        self.type = type
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    public init(selectTab index: Int, and transaction: WithTransaction? = .none) {
        self.type = .selectTab
        self.tabIndex = index
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }

    public init(with alert: Alert, and transaction: WithTransaction? = .none) {
        self.type = .alert
        self.alert = .init(value: alert)
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    public init(with error: Error, and alertTitle: String? = nil, transaction: WithTransaction? = .none) {
        self.type = .alert
        self.alert = .init(value: SRTransition.alert(from: error, with: alertTitle))
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    public init(with route: RouteType, and action: SRTransitionType, transaction: WithTransaction? = .none) {
        precondition(action != .present, "macOS didn't support fullScreenCover")
        precondition(action != .actionSheet, "macOS didn't support actionSheet")
        self.type = action
        self.route = route
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    
    public init(popTo route: some SRRoute, and transaction: WithTransaction? = .none) {
        self.type = .popToRoute
        self.popToRoute = route
        self.contextId = TimeIdentifier()
        self.transaction = transaction
    }
    #endif
    
    private static func alert(from error: Error,
                       with title: String?) -> Alert {
        
        Alert.init(title: Text(title ?? ""),
                   message: Text(error.localizedDescription),
                   dismissButton: .cancel(Text("OK")))
    }
}

extension SRTransition {
    public static var none: SRTransition {
        SRTransition(with: .none)
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
