//
//  TransitionType.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

/// Transition type of navigation for the trigger action.
public enum TriggerType: String, CaseIterable {
    /// Push a screen
    case push
    /// Present full screen
    case present
    /// Present a  screen
    case sheet
}

/// Transition type of navigation that using internal.
enum TransitionType: String, CaseIterable {
    case none
    /// Push a screen
    case push
    /// Present full screen
    case present
    /// Select a tabbar item
    case selectTab
    /// Show alert
    case alert
    /// Present a  screen
    case sheet
    /// Dismiss(pop) screen
    case dismiss
    /// Dismiss to root screen
    case dismissAll
    
    init(with triggerType: TriggerType) {
        switch triggerType {
        case .push: self = .push
        case .present: self = .present
        case .sheet: self = .sheet
        }
    }
}
