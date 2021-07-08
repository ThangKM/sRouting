//
//  Transition.swift
//  
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

struct Transition<RouteType> where RouteType: Route {
    
    let type: TransitionType
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
    #endif
    
    init(with type: TransitionType) {
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
        alert = Transition.alert(from: error, with: alertTitle)
    }
    
    init(with route: RouteType, and action: TransitionType) {
        precondition(OSEnvironment.current != .macOS || action != .present, "macOS didn't support fullScreenCover")
        precondition(OSEnvironment.current != .macOS || action != .actionSheet, "macOS didn't support actionSheet")
        self.type = action
        self.route = route
        self.alert = nil
        tabIndex = nil
    }
    
    private static func alert(from error: Error,
                       with title: String?) -> Alert {
        
        Alert.init(title: Text(title ?? ""),
                   message: Text(error.localizedDescription),
                   dismissButton: .cancel(Text("OK")))
    }
}

extension Transition {
    static var none: Transition {
        Transition(with: .none)
    }
}

extension Transition: Equatable {
    /// Conform Equatable
    /// - Parameters:
    ///   - lhs: left value
    ///   - rhs: right value
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type
    }
}
