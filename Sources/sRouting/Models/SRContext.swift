//
//  SRContext.swift
//
//
//  Created by Thang Kieu on 29/03/2024.
//

import Foundation

struct SRContext {
    
    /// Generate context id for a transition
    ///
    /// - Returns: time context id
    static func newContextId() -> String {
        let formater = DateFormatter()
        formater.dateStyle = .short
        formater.timeStyle = .medium
        let timeId = formater.string(from: Date())
        return timeId
    }
}
