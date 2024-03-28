//
//  SRTransition.swift
//
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

@MainActor
public struct SRTransition<RouteType: SRRoute> {
    
    let contextId: String
    let type: SRTransitionType
    let route: RouteType?
    let alert: Alert?
    let tabIndex: Int?
    let popToRoute: (any SRRoute)?
    
    #if os(iOS) || os(tvOS)
    let actionSheet: ActionSheet?
    
    public init(with actionSheet: ActionSheet) {
        self.type = .actionSheet
        route = nil
        tabIndex = nil
        alert = nil
        self.actionSheet = actionSheet
        popToRoute = nil
        contextId = Self._contextId()
    }
  
    public init(with type: SRTransitionType) {
        self.type = type
        route = nil
        alert = nil
        tabIndex = nil
        actionSheet = nil
        popToRoute = nil
        contextId = Self._contextId()
    }
    
    public init(selectTab index: Int) {
        type = .selectTab
        tabIndex = index
        route = nil
        alert = nil
        actionSheet = nil
        popToRoute = nil
        contextId = Self._contextId()
    }

    public init(with alert: Alert) {
        self.type = .alert
        route = nil
        tabIndex = nil
        self.alert = alert
        actionSheet = nil
        popToRoute = nil
        contextId = Self._contextId()
    }
    
    public init(with error: Error, and alertTitle: String? = nil) {
        self.type = .alert
        route = nil
        tabIndex = nil
        alert = SRTransition.alert(from: error, with: alertTitle)
        actionSheet = nil
        popToRoute = nil
        contextId = Self._contextId()
    }
    
    public init(with route: RouteType, and action: SRTransitionType) {
        self.type = action
        self.route = route
        self.alert = nil
        tabIndex = nil
        actionSheet = nil
        popToRoute = nil
        contextId = Self._contextId()
    }
    
    public init(popTo route: some SRRoute) {
        self.type = .popToRoute
        self.route = nil
        self.alert = nil
        tabIndex = nil
        actionSheet = nil
        popToRoute = route
        contextId = Self._contextId()
    }
    
    #else
    public init(with type: SRTransitionType) {
        self.type = type
        route = nil
        alert = nil
        tabIndex = nil
        popToRoute = nil
        contextId = Self._contextId()
    }
    
    public init(selectTab index: Int) {
        type = .selectTab
        tabIndex = index
        route = nil
        alert = nil
        popToRoute = nil
        contextId = Self._contextId()
    }

    public init(with alert: Alert) {
        self.type = .alert
        route = nil
        tabIndex = nil
        self.alert = alert
        popToRoute = nil
        contextId = Self._contextId()
    }
    
    public init(with error: Error, and alertTitle: String? = nil) {
        self.type = .alert
        route = nil
        tabIndex = nil
        alert = SRTransition.alert(from: error, with: alertTitle)
        popToRoute = nil
        contextId = Self._contextId()
    }
    
    public init(with route: RouteType, and action: SRTransitionType) {
        precondition(action != .present, "macOS didn't support fullScreenCover")
        precondition(action != .actionSheet, "macOS didn't support actionSheet")
        self.type = action
        self.route = route
        self.alert = nil
        tabIndex = nil
        popToRoute = nil
        contextId = Self._contextId()
    }
    
    public init(popTo route: some SRRoute) {
        self.type = .popToRoute
        self.route = nil
        self.alert = nil
        tabIndex = nil
        popToRoute = route
        contextId = Self._contextId()
    }
    #endif
    
    private static func alert(from error: Error,
                       with title: String?) -> Alert {
        
        Alert.init(title: Text(title ?? ""),
                   message: Text(error.localizedDescription),
                   dismissButton: .cancel(Text("OK")))
    }
    
    /// Generate context id for a transition
    ///
    /// - Returns: time context id
    private static func _contextId() -> String {
        let formater = DateFormatter()
        formater.dateStyle = .short
        formater.timeStyle = .medium
        let timeId = formater.string(from: Date())
        return timeId
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
