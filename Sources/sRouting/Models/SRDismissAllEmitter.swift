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
    
    private(set) var dismissAllSignal: SignalChange = false
    
    private(set) var dismissCoordinatorSignal: SignalChange = false
    
    public init() { }
    
    public func dismissAll() {
        dismissAllSignal.toggle()
    }
    
    public func dismissCoordinator() {
        dismissCoordinatorSignal.toggle()
    }
}
