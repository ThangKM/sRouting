//
//  ActionStore.swift
//  Bookie
//
//  Created by Thang Kieu on 16/1/25.
//

import Foundation

@MainActor
protocol ActionStore {
    
    associatedtype Action: Sendable
    
    func receive(action: Action)
}
