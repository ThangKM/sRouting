//
//  SRRootView.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI

public struct SRRootView<Content>: View where Content: View {
    
    @Bindable private var dismissAllEmitter: SRDismissAllEmitter
    private let content: () -> Content
    
    public init(dsaEmitter: SRDismissAllEmitter,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.dismissAllEmitter = dsaEmitter
    }
    
    public var body: some View {
        content().environment(dismissAllEmitter)
    }
}
