//
// OnDismissAllChange.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI

private typealias OnChangeBlock = @MainActor () -> Void

private struct RootModifier: ViewModifier {
    
    @EnvironmentObject
    private var context: SRContext
    
    private let onChange: OnChangeBlock
    
    init(_ onChange: @escaping OnChangeBlock)  {
        self.onChange = onChange
    }
    
    func body(content: Content) -> some View {
        content.onChange(of: context.dismissAllSignal) { _ in
            onChange()
        }
    }
}

extension View {
    
    /// Observe Dismiss all change
    /// - Parameter onChange: action
    /// - Returns: some `View`
    public func onDismissAllChange(_ onChange: @escaping @MainActor () -> Void) -> some View {
        self.modifier(RootModifier(onChange))
    }
}
