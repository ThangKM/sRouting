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
        formater.dateFormat = "HH:mm:ss.S"
        let timeId = formater.string(from: Date())
        return timeId
    }
}
