//
//  OnNavigationStackChange.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI

private typealias OnChangeBlock = @MainActor (_ oldPaths: [String], _ newPaths: [String]) -> Void

private struct NavigationModifier: ViewModifier {
    
    @Environment(SRNavigationPath.self)
    private var navigationPath: SRNavigationPath?
    
    private let onChange: OnChangeBlock
    
    init(_ onChange: @escaping OnChangeBlock)  {
        self.onChange = onChange
    }
    
    func body(content: Content) -> some View {
        content.onChange(of: navigationPath?.stack) { oldValue, newValue in
            let oldPaths = (oldValue ?? [])
            let newPahts = (newValue ?? [])
            onChange(oldPaths, newPahts)
        }
    }
}

extension View {
    
    /// Observe Navigation stack change
    /// - Parameter onChange: action
    /// - Returns: some `View`
    public func onNaviStackChange(_ onChange: @escaping @MainActor (_ oldPaths: [String], _ newPaths: [String]) -> Void) -> some View {
        self.modifier(NavigationModifier(onChange))
    }
}
