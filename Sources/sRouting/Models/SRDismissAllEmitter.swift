//
//  SRDismissAllEmitter.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation
import Observation

/// `Dismiss all` signal emitter
@Observable @MainActor
public final class SRDismissAllEmitter {
    
    internal var dismissAllSignal: Int = .zero
    
    public init() { }
    
    public func dismissAll() {
        dismissAllSignal = if dismissAllSignal == .zero { 1 } else { .zero }
    }
}
