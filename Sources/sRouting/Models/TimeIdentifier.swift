//
//  TimeIdentifier.swift
//
//
//  Created by Thang Kieu on 29/03/2024.
//

import Foundation

struct TimeIdentifier {
    
    /// Generate context id for a transition
    ///
    /// - Returns: time id
    static func newId() -> String {
        let formater = DateFormatter()
        formater.dateStyle = .short
        formater.timeStyle = .medium
        let timeId = formater.string(from: Date())
        return timeId
    }
}
