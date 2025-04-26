//
//  OnShowLoadingModifier.swift
//  Bookie
//
//  Created by Thang Kieu on 27/4/25.
//

import SwiftUI

struct OnShowLoadingModifier: ViewModifier {
    
    @Binding var isLoading: Bool

    func body(content: Content) -> some View {
        content
            .overlay(content: {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.accent)
                    .opacity(isLoading ? 1 : 0)
                    .animation(.easeInOut, value: isLoading)
            })
    }
}

extension View {
    public func onShowLoading(_ isLoading: Binding<Bool>) -> some View {
        modifier(OnShowLoadingModifier(isLoading: isLoading))
    }
}
