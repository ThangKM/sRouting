//
//  NavigationRootView.swift
//
//
//  Created by Thang Kieu on 20/03/2024.
//

import SwiftUI
import Observation

/// Inject ``SRNavigationPath`` environment value before observing the navigation's route transitions
public struct NavigationStackView<Content>: View
where Content: View {
    
    @ObservedObject var path: SRNavigationPath
    private let content: () -> Content

    /// Initalizer of ``NavigationRootView``
    ///  - Parameters:
    ///     - path: ``SRNavigationPath``
    ///     - content: Content view builder
    public init(path: SRNavigationPath,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.path = path
    }
    
    public var body: some View {
        NavigationStack(path: $path.navPath, root: {
            content()
        })
        .environmentObject(path)
        .onAppear(perform: {
            path.stackDidAppear()
        })
    }
}

extension NavigationLink where Destination == Never {

    public init<R>(route: R, @ViewBuilder content: () -> Label) where R: SRRoute {
        self.init(value: route, label: content)
    }
}
