//
//  SRCoordinatorEmitter.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation
import Observation

/// `Dismiss the coordinator` signal emitter
@Observable @MainActor
public final class SRCoordinatorEmitter {
    
    internal var doubleTapTabItemEmmiter: SignalChange = false
    
    private(set) var dismissEmitter: SignalChange = false
    
    public var tabSelection: Int = .zero {
        willSet {
            guard newValue == _tabSelection else {
                lastReselect = nil
                return
            }
            _handleReselect()
        }
    }
    
    /// Time of the last re-selection of the current tab, used to detect a double tap.
    @ObservationIgnored
    private var lastReselect: ContinuousClock.Instant?
    
    private let doubleTapInterval: Duration = .milliseconds(400)
    
    public init() { }
    
    public func select(tag: Int) {
        tabSelection = tag
    }
    
    /// Dismiss the coordinator
    internal func dismiss() {
        dismissEmitter.toggle()
    }
    
    private func _handleReselect() {
        let now = ContinuousClock.now
        if let lastReselect, now - lastReselect < doubleTapInterval {
            self.lastReselect = nil
            doubleTapTabItemEmmiter.toggle()
        } else {
            lastReselect = now
        }
    }
}
