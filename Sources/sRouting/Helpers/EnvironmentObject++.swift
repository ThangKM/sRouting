//
//  EnvironmentObject++.swift
//  sRouting
//
//  Created by Thang Kieu on 10/4/25.
//

import SwiftUI

extension EnvironmentObject {
    var presence: Bool {
        !String(describing: self).contains("_store: nil")
    }
}
