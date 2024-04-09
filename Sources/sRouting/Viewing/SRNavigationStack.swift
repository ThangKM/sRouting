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
                route.screen.environment(path)
            }
        }
        .environment(path)
        .onAppear(perform: {
            path.stackDidAppear()
        })
    }
}

extension NavigationLink where Destination == Never {

    public init<R>(route: R, @ViewBuilder content: () -> Label) where R: SRRoute {
        self.init(value: AnyRoute(route: route), label: content)
    }
}
