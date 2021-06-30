//
//  Binding+Extension.swift
//  Sequence
//
//  Created by ThangKieu on 2/20/21.
//

import SwiftUI

@available(iOS 15.0, *)
extension Binding {
    func willSet(execute: @escaping (Value) -> Void) -> Binding {
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
