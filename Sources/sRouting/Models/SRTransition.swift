//
//  SRTransition.swift
//
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

public struct SRTransition<RouteType>
where RouteType: SRRoute {
    
    let contextId: String
    let type: SRTransitionType
    private(set) var route: RouteType?
    private(set) var alert: Alert?
    private(set) var tabIndex: Int?
    private(set) var popToRoute: (any SRRoute)?
    private(set) var windowTransition: SRWindowTransition?

    #if os(iOS) || os(tvOS)
    private(set) var actionSheet: ActionSheet?
    
    public init(with actionSheet: ActionSheet) {
        self.type = .actionSheet
        self.contextId = TimeIdentifier.newId()
        self.actionSheet = actionSheet
    }
  
    public init(with type: SRTransitionType) {
        self.type = type
        self.contextId = TimeIdentifier.newId()
    }
    
    public init(selectTab index: Int) {
        self.type = .selectTab
        self.contextId = TimeIdentifier.newId()
        self.tabIndex = index
    }

    public init(with alert: Alert) {
        self.type = .alert
        self.contextId = TimeIdentifier.newId()
        self.alert = alert
    }
    
    public init(with error: Error, and alertTitle: String? = nil) {
        self.type = .alert
        self.contextId = TimeIdentifier.newId()
        self.alert = SRTransition.alert(from: error, with: alertTitle)
    }
    
    public init(with route: RouteType, and action: SRTransitionType) {
        self.type = action
        self.route = route
        self.contextId = TimeIdentifier.newId()
        self.alert = nil
    }
    
    public init(popTo route: some SRRoute) {
        self.type = .popToRoute
        self.popToRoute = route
        self.contextId = TimeIdentifier.newId()
    }
    
    public init(with type: SRTransitionType,
                windowTransition: SRWindowTransition) {
        self.contextId = TimeIdentifier.newId()
        self.type = type
        self.windowTransition = windowTransition
    }
    #else
    public init(with type: SRTransitionType,
                windowTransition: SRWindowTransition) {
        self.contextId = TimeIdentifier.newId()
        self.type = type
        self.windowTransition = windowTransition
    }
    
    public init(with type: SRTransitionType) {
        self.type = type
        self.contextId = TimeIdentifier.newId()
    }
    
    public init(selectTab index: Int) {
        self.type = .selectTab
        self.tabIndex = index
        self.contextId = TimeIdentifier.newId()
    }

    public init(with alert: Alert) {
        self.type = .alert
        self.alert = alert
        self.contextId = TimeIdentifier.newId()
    }
    
    public init(with error: Error, and alertTitle: String? = nil) {
        self.type = .alert
        self.alert = SRTransition.alert(from: error, with: alertTitle)
        self.contextId = TimeIdentifier.newId()
    }
    
    public init(with route: RouteType, and action: SRTransitionType) {
        precondition(action != .present, "macOS didn't support fullScreenCover")
        precondition(action != .actionSheet, "macOS didn't support actionSheet")
        self.type = action
        self.route = route
        self.contextId = TimeIdentifier.newId()
    }
    
    public init(popTo route: some SRRoute) {
        self.type = .popToRoute
        self.popToRoute = route
        self.contextId = TimeIdentifier.newId()
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
