//
//  OnDoubleTapTabItem.swift
//
//
//  Created by Thang Kieu on 9/4/24.
//

import SwiftUI

private typealias OnChangeBlock = @MainActor (Int) -> Void

private struct OnDoubleTapTabItem: ViewModifier {
    
    @Environment(SRTabbarSelection.self)
    private var tabSelection: SRTabbarSelection?
    
    private let onChange: OnChangeBlock
    
    init(_ onChange: @escaping OnChangeBlock)  {
        self.onChange = onChange
    }
    
    func body(content: Content) -> some View {
        content.onChange(of: tabSelection?.doubleTapEmmiter) { _, _ in
            guard let selection = tabSelection?.selection else { return }
            onChange(selection)
        }
    }
}

extension View {
    
    /// Observe double tap event on tabItem
    /// - Parameter onChange: action
    /// - Returns: some `View`
    public func onDoubleTapTabItem(_ onChange: @escaping @MainActor (_ selection: Int) -> Void) -> some View {
        self.modifier(OnDoubleTapTabItem(onChange))
    }
}
