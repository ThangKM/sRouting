//
//  SRDismissAllEmitter.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation
import Observation

/// `Dismiss all` signal emitter
@MainActor
public final class SRDismissAllEmitter: ObservableObject {
    
    @Published
    private(set) var dismissAllSignal: SignalChange = false
    
    @Published
    private(set) var dismissCoordinatorSignal: SignalChange = false
    
    public init() { }
    
    public func dismissAll() {
        dismissAllSignal.toggle()
    }
    
    public func dismissCoordinator() {
        dismissCoordinatorSignal.toggle()
    }
}
