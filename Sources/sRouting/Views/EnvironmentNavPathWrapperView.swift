//
//  EnvironmentNavPathWrapperView.swift
//
//
//  Created by Thang Kieu on 20/03/2024.
//

import SwiftUI
import Observation


/// Inject ``SRNavigationPath`` environment value before observing the navigation's route transitions
public struct EnvironmentNavPathWrapperView<Content>: View
where Content: View {
    
    private let path: SRNavigationPath
    private let content: () -> Content

    /// Initalizer of ``EnviromentNavPathWrapperView``
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
        .environment(path)
        .onAppear(perform: {
            path.stackDidAppear()
        })
    }
}

extension NavigationStack where Data == NavigationPath {
    
    public init<Content: View>(path: SRNavigationPath, @ViewBuilder root: @escaping () -> Content)
    where Root == EnvironmentNavPathWrapperView<Content> {
        @Bindable var bindPath = path
        self.init(path: $bindPath.navPath) {
            EnvironmentNavPathWrapperView(path: path, content: root)
        }
    }
}

extension NavigationLink where Destination == Never {

    public init<R>(route: R, @ViewBuilder content: () -> Label) where R: SRRoute {
        self.init(value: route, label: content)
    }
}
