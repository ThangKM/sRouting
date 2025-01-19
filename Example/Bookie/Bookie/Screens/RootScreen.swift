//
//  RootScreen.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import sRouting
import SwiftUI

struct RootScreen: View {
    
    @State private var startHome = false
    
    private var showHomeAcion: AsyncActionPut<Bool> {
        .init { @MainActor value in
            withAnimation {
                startHome = value
            }
        }
    }
    
    var body: some View {
        if startHome {
            AppRoute.homeScreen.screen
                .transition(.asymmetric(insertion: .scale(scale: 3), removal: .scale(scale: 0.2)).combined(with: .opacity))
                .animation(.easeInOut(duration: 1), value: 1)
        } else {
            AppRoute.startScreen(startAction: showHomeAcion)
            .screen
                .transition(.asymmetric(insertion: .scale(scale: 0.2), removal: .scale(scale: 0.2)).combined(with: .opacity))
                .animation(.easeInOut(duration: 1), value: 1)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(MockBookPreviewModifier())) {
    RootPreview {
        RootScreen()
    }
}
