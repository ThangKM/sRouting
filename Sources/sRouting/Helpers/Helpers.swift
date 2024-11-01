//
//  Helpers.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import Foundation

typealias SignalChange = Bool

struct UncheckedSendable<V>: @unchecked Sendable {
    
    let value: V
    
    init(value: V) {
        self.value = value
    }
}
