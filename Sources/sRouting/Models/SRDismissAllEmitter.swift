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
    
    internal var dismissAllSignal: SignalChange = false
    
    public init() { }
    
    public func dismissAll() {
        dismissAllSignal = !dismissAllSignal
    }
}
