//
//  SRRootView.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI
import Observation

/// The root view of a window
public struct SRRootView<Content, ContextType>: View
where Content: View, ContextType: SRContextType {

    private let context: ContextType
    private let content: () -> Content
    
    public init(context: ContextType,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.context = context
    }
    
    public var body: some View {
        content()
            .onRouting(of:context.rootRouter)
            .environmentObject(context.dismissAllEmitter)
            .environmentObject(context.tabSelection)
    }
}
