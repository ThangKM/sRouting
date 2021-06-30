//
//  Binding+Extension.swift
//  sRouting
//
//  Created by ThangKieu on 6/30/21.
//

import SwiftUI

extension Binding {
    internal func willSet(execute: @escaping (Value) -> Void) -> Binding {
        return Binding(
            get: {
                return self.wrappedValue
            },
            set: {
                execute($0)
                self.wrappedValue = $0
            }
        )
    }
}
