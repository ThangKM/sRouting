//
//  SRNavigationStack.swift
//
//
//  Created by Thang Kieu on 20/03/2024.
//

import SwiftUI
import Observation

public struct SRNavigationStack<Content>: View where Content: View {
    
    @Bindable private var path: SRNavigationPath
    
    private let content: () -> Content

    /// Initalizer of ``SRNavigationStack``
    ///  - Parameters:
    ///   - path: ``SRNavigationPath``
    ///   - content: Content view builder
    public init(path: SRNavigationPath, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.path = path
    }
    
    public var body: some View {
        NavigationStack(path: $path.stack) {
            content()
            .navigationDestination(for: AnyRoute.self) { route in
                #if os(iOS)
                route.screen
                #else
                route.screen.environment(path)
                #endif
            }
        }.environment(path)
    }
}

