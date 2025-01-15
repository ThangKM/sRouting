//
//  ViewStore.swift
//  Bookie
//
//  Created by Thang Kieu on 16/1/25.
//

import Foundation

/// Using @StateObject to synchronize the lifecycle of the ViewStore with the lifecycle of the view.
///
/// ViewStore never sends changes directly to the view; instead, it modifies the ViewState.
///  To achieve this, we use @StateObject to synchronize the lifecycle of ViewStore with the View,
///  thereby avoiding the unnecessary generation of code from the @Observable macro.
@MainActor
protocol ViewStore: ObservableObject {
    
    associatedtype Action: Sendable
    associatedtype State: Sendable
    
    func receive(action: Action)
    
    func binding(state: State)
}

