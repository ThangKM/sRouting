//
//  DatabaseProvider.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import Foundation
import SwiftData

final class DatabaseProvider: Sendable {
    
    static let shared = DatabaseProvider()
    let container: ModelContainer
    
    private init() {
        switch EnvironmentRunner.current {
        case .livePreview:
            do {
                let config = ModelConfiguration(for: BookPersistent.self, isStoredInMemoryOnly: true)
                container = try ModelContainer(for: BookPersistent.self, configurations: config)
            } catch {
                fatalError("Failed to initialize database: \(error)")
            }
        default:
            do {
                container = try ModelContainer(for: BookPersistent.self)
            } catch {
                fatalError("Failed to initialize database: \(error)")
            }
        }
    }
}

