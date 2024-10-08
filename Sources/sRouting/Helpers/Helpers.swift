//
//  Helpers.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import Foundation

typealias SignalChange = Bool

struct Helpers {
    
    static func navigationStoredPath(for route: some SRRoute) -> String {
        String(describing: type(of: route)) + "." + route.formatedPath
    }
}

struct UncheckedSendable<V>: @unchecked Sendable {
    
    let value: V
    
    init(value: V) {
        self.value = value
    }
}
