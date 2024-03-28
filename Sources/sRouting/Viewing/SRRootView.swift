//
//  SRRootView.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI

@Observable @MainActor
internal final class SRDismisAllEmitter {
    
    var dismissAllSignal: Int = .zero
    
    func dismissAll() {
        dismissAllSignal = if dismissAllSignal == .zero { 1 } else { .zero }
    }
}

@MainActor
public struct SRRootView<Content>: View where Content: View {
    
    @State private var dismissAllEmitter: SRDismisAllEmitter = .init()
    private let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content().environment(dismissAllEmitter)
    }
}
