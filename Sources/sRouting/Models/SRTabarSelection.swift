//
//  SRTabarSelection.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation

/// Tabar's selection Observation
@Observable
public final class SRTabarSelection {
    
    @MainActor
    internal var selection: Int = 0
    
    public init() { }
    
    @MainActor
    public func select(tag: Int) {
        selection = tag
    }
}
