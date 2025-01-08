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
    
    @Published var dismissAllSignal: SignalChange = false
    
    public init() { }
    
    public func dismissAll() {
        dismissAllSignal.toggle()
    }
}
