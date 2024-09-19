//
//  SRNavigationStack.swift
//
//
//  Created by Thang Kieu on 20/03/2024.
//

import SwiftUI
import Observation

public struct SRNavigationStack<ObserveView, Content>: View
where ObserveView: (View & SRObserveViewType), Content: View, ObserveView.ObserveContent == Content {
    
    private let path: SRNavigationPath
    
    private let content: () -> Content

    /// Initalizer of ``SRNavigationStack``
    ///  - Parameters:
    ///   - content: Content view builder
    ///   - observeView: ``SRObserveViewType``
    public init(path: SRNavigationPath,
                observeView: ObserveView.Type,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.path = path
    }
    
    public var body: some View {
        NavigationStack(path: .init(get: {
            path.navPath
        }, set: { newPath in
            path.navPath = newPath
        })) {
            ObserveView(path: path) {
                content()
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
        self.init(value: route, label: content)
    }
}
