//
//  SRDismissAllEmitter.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation
import Observation

/// `Dismiss all` signal emitter
@Observable
public final class SRDismissAllEmitter: Sendable {
    
    @MainActor
    internal var dismissAllSignal: Int = .zero
    
    public init() { }
    
    @MainActor
    public func dismissAll() {
        dismissAllSignal = if dismissAllSignal == .zero { 1 } else { .zero }
    }
}
