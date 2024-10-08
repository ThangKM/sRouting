//
//  OnTabSelectionChange.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI

private typealias OnChangeBlock = @MainActor (Int) -> Void

private struct TabbarModifier: ViewModifier {
    
    @Environment(SRTabbarSelection.self)
    private var tabSelection: SRTabbarSelection?
    
    private let onChange: OnChangeBlock
    
    init(_ onChange: @escaping OnChangeBlock)  {
        self.onChange = onChange
    }
    
    func body(content: Content) -> some View {
        content.onChange(of: tabSelection?.selection) { oldValue, newValue in
            guard let newValue else { return }
            onChange(newValue)
        }
    }
}

extension View {
    
    /// Observe `TabView`'s selection
    /// - Parameter onChange: action
    /// - Returns: some `View`
    public func onTabSelectionChange(_ onChange: @escaping @MainActor (_ selection: Int) -> Void) -> some View {
        self.modifier(TabbarModifier(onChange))
    }
}
