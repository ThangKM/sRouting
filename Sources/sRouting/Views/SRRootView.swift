//
//  SRRootView.swift
//
//
//  Created by Thang Kieu on 28/03/2024.
//

import SwiftUI
import Observation

/// The root view of a window
public struct SRRootView<Content, Coordinator>: View
where Content: View, Coordinator: SRRouteCoordinatorType {

    private let coordinator: Coordinator
    private let content: () -> Content
    
    public init(coordinator: Coordinator,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.coordinator = coordinator
    }
    
    public var body: some View {
        content()
            .onRouting(of:coordinator.rootRouter)
            .environmentObject(coordinator.dismissAllEmitter)
            .environmentObject(coordinator.tabSelection)
    }
}
