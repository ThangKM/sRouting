//
//  NavigationRootView.swift
//
//
//  Created by Thang Kieu on 20/03/2024.
//

import SwiftUI
import Observation

/// Inject ``SRNavigationPath`` environment value before observing the navigation's route transitions
public struct NavigationRootView<Content>: View
where Content: View {
    
    private let path: SRNavigationPath
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
        content()
        .environmentObject(path)
        .onAppear(perform: {
            path.stackDidAppear()
        })
    }
}

extension NavigationStack where Data == NavigationPath {
    
    public init<Content: View>(manager: SRNavigationPath, path: Binding<NavigationPath>, @ViewBuilder root: @escaping () -> Content)
    where Root == NavigationRootView<Content> {
        self.init(path: path) {
            NavigationRootView(path: manager, content: root)
        }
    }
}


extension NavigationLink where Destination == Never {

    public init<R>(route: R, @ViewBuilder content: () -> Label) where R: SRRoute {
        self.init(value: route, label: content)
    }
}
