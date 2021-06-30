//
//  TransitionType.swift
//  Sequence
//
//  Created by ThangKieu on 2/10/21.
//

import SwiftUI

public enum TransitionType: String, CaseIterable {
    case none
    case push
    case present
    case selectTab
    case alert
    case sheet
    case dismiss
    case dismissAll
}

@available(iOS 15.0, *)
struct Transition<RouteType> where RouteType: Route {
    
    let type: TransitionType
    let screenView: RouteType.ViewType?
    let alert: Alert?
    let tabIndex: Int?
    
    init(with type: TransitionType) {
        self.type = type
        screenView = nil
        alert = nil
        tabIndex = nil
    }
    
    init(selectTab index: Int) {
        type = .selectTab
        tabIndex = index
        screenView = nil
        alert = nil
    }
    
    init(with error: Error, and alertTitle: String? = nil) {
        self.type = .alert
        screenView = nil
        tabIndex = nil
        alert = Transition.alert(from: error, with: alertTitle)
    }
    
    init(with route: RouteType, and action: TransitionType) {
        self.type = action
        self.screenView = route.screen
        self.alert = route.alert
        tabIndex = nil
    }
    
    private static func alert(from error: Error,
                       with title: String?) -> Alert {
        
        Alert.init(title: Text(title ?? ""),
                   message: Text(error.localizedDescription),
                   dismissButton: .cancel(Text("OK")))
    }
}

@available(iOS 15.0, *)
extension Transition {
    static var none: Transition {
        Transition(with: .none)
    }
}

@available(iOS 15.0, *)
extension Transition: Equatable {
    /// Conform Equatable
    /// - Parameters:
    ///   - lhs: left value
    ///   - rhs: right value
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type
    }
}
