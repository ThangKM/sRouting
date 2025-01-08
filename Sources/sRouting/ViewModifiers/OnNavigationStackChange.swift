//
//  OnNavigationStackChange.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI

private typealias OnChangeBlock = @MainActor (_ newPaths: [String]) -> Void

private struct NavigationModifier: ViewModifier {
    
    @EnvironmentObject
    private var navigationPath: SRNavigationPath
    
    private let onChange: OnChangeBlock
    
    init(_ onChange: @escaping OnChangeBlock)  {
        self.onChange = onChange
    }
    
    func body(content: Content) -> some View {
        content.onReceive(navigationPath.$stack.dropFirst().onChanges()) { path in
            onChange(path)
        }
    }
}

extension View {
    
    /// Observe Navigation stack change
    /// - Parameter onChange: action
    /// - Returns: some `View`
    public func onNaviStackChange(_ onChange: @escaping @MainActor (_ newPaths: [String]) -> Void) -> some View {
        self.modifier(NavigationModifier(onChange))
    }
}
