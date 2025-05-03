//
//  TimeIdentifier.swift
//
//
//  Created by Thang Kieu on 29/03/2024.
//

import Foundation

public struct TimeIdentifier: Sendable, Hashable, CustomStringConvertible, Identifiable {

    public let id: String
    
    public var description: String {
        id
    }
    
    public static var now: TimeIdentifier {
        .init()
    }
    
    private static var formatter: DateFormatter {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd, HH:mm:ss.S"
        return formater
    }
    
    public init() {
        self.id = Self.formatter.string(from: .now)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: TimeIdentifier, rhs: TimeIdentifier) -> Bool {
        lhs.id == rhs.id
    }
}
