//
//  SRRootView.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI
import Observation

public struct SRRootView<Content, ContextType>: View
where Content: View, ContextType: SRContextType {

    @Environment(\.dismiss)
    private var dismiss
    private var context: ContextType
    private let content: () -> Content
    
    public init(context: ContextType,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.context = context
    }
    
    public var body: some View {
        ScreenView(router: context.rootRouter, dismissAction: dismiss) {
            content()
        }
        .environment(context.dismissAllEmitter)
        .environment(context.tabSelection)
    }
}
