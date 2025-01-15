//
//  ViewStore.swift
//  Bookie
//
//  Created by Thang Kieu on 16/1/25.
//

import Foundation

@MainActor
protocol ViewStore: ObservableObject {
    
    associatedtype Action: Sendable
    associatedtype State: Sendable
    
    func receive(action: Action)
    
    func binding(state: State)
}
