//
//  SRTransition.swift
//
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

struct SRTransition<RouteType> where RouteType: Route {
    
    let type: SRTransitionType
    let route: RouteType?
    let alert: Alert?
    let tabIndex: Int?
    
    #if os(iOS) || os(tvOS)
    let actionSheet: ActionSheet?
    
    init(with actionSheet: ActionSheet) {
        self.type = .actionSheet
        route = nil
        tabIndex = nil
        alert = nil
        self.actionSheet = actionSheet
    }
  
    init(with type: SRTransitionType) {
        self.type = type
        route = nil
        alert = nil
        tabIndex = nil
        actionSheet = nil
    }
    
    init(selectTab index: Int) {
        type = .selectTab
        tabIndex = index
        route = nil
        alert = nil
        actionSheet = nil
    }

    init(with alert: Alert) {
        self.type = .alert
        route = nil
        tabIndex = nil
        self.alert = alert
        actionSheet = nil
    }
    
    init(with error: Error, and alertTitle: String? = nil) {
        self.type = .alert
        route = nil
        tabIndex = nil
        alert = SRTransition.alert(from: error, with: alertTitle)
        actionSheet = nil
    }
    
    init(with route: RouteType, and action: SRTransitionType) {
        self.type = action
        self.route = route
        self.alert = nil
        tabIndex = nil
        actionSheet = nil
    }
    #else
    init(with type: SRTransitionType) {
        self.type = type
        route = nil
        alert = nil
        tabIndex = nil
    }
    
    init(selectTab index: Int) {
        type = .selectTab
        tabIndex = index
        route = nil
        alert = nil
    }

    init(with alert: Alert) {
        self.type = .alert
        route = nil
        tabIndex = nil
        self.alert = alert
    }
    
    init(with error: Error, and alertTitle: String? = nil) {
        self.type = .alert
        route = nil
        tabIndex = nil
        alert = SRTransition.alert(from: error, with: alertTitle)
    }
    
    init(with route: RouteType, and action: SRTransitionType) {
        precondition(action != .present, "macOS didn't support fullScreenCover")
        precondition(action != .actionSheet, "macOS didn't support actionSheet")
        self.type = action
        self.route = route
        self.alert = nil
        tabIndex = nil
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
    static var none: SRTransition {
        SRTransition(with: .none)
    }
}

extension SRTransition: Equatable {
    /// Conform Equatable
    /// - Parameters:
    ///   - lhs: left value
    ///   - rhs: right value
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type
    }
}
