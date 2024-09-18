//
//  TimeIdentifier.swift
//
//
//  Created by Thang Kieu on 29/03/2024.
//

import Foundation

struct TimeIdentifier: Sendable, Hashable, CustomStringConvertible, Identifiable {

    let id: String
    
    var description: String {
        id
    }
    
    private static var formatter: DateFormatter {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd, HH:mm:ss.S"
        return formater
    }
    
    init() {
        self.id = Self.formatter.string(from: .now)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TimeIdentifier, rhs: TimeIdentifier) -> Bool {
        lhs.id == rhs.id
    }
}
