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
    private let context: SRContext
    private let content: () -> Content
    
    public init(context: SRContext,
                coordinator: Coordinator,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.coordinator = coordinator
        self.context = context
    }
    
    public var body: some View {
        content()
            .onChange(of: coordinator.emitter.dismissEmiiter, { _ , _ in
                coordinator.rootRouter.dismiss()
            })
            .onAppear {
                context.registerActiveCoordinator(coordinator)
            }
            .onDisappear(perform: {
                context.resignActiveCoordinator(identifier: coordinator.identifier)
            })
            .onRouting(of: coordinator.rootRouter)
            .environment(context)
            .environment(coordinator.emitter)
    }
}
