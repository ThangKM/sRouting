//
//  OnDoubleTapTabItem.swift
//
//
//  Created by Thang Kieu on 9/4/24.
//

import SwiftUI

private typealias OnChangeBlock = @MainActor (Int) -> Void

private struct OnDoubleTapTabItem: ViewModifier {
    
    @EnvironmentObject
    private var tabSelection: SRTabbarSelection
    
    private let onChange: OnChangeBlock
    
    init(_ onChange: @escaping OnChangeBlock)  {
        self.onChange = onChange
    }
    
    func body(content: Content) -> some View {
        content.onReceive(tabSelection.$doubleTapEmmiter.onChanges()) { _ in
            let selection = tabSelection.selection
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
