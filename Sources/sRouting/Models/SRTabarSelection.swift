//
//  SRTabbarSelection.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation

/// Tabbar's selection Observation
@Observable
public final class SRTabbarSelection {
    
    @MainActor
    internal var selection: Int = 0
    
    public init() { }
    
    @MainActor
    public func select(tag: Int) {
        selection = tag
    }
}
