//
//  OnTabSelectionChange.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI

private typealias OnChangeBlock = @MainActor (Int) -> Void

private struct TabbarModifier: ViewModifier {
    
    @EnvironmentObject
    private var emitter: SRCoordinatorEmitter
    
    private let onChange: OnChangeBlock
    
    init(_ onChange: @escaping OnChangeBlock)  {
        self.onChange = onChange
    }
    
    func body(content: Content) -> some View {
        content.onChange(of: emitter.tabSelection) { newValue in
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
