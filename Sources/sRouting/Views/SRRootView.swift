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
where Content: View, Coordinator: SRRouteCoordinatorType, Coordinator: ObservableObject {
    
    @ObservedObject
    private var coordinator: Coordinator
    
    @ObservedObject
    private var context: SRContext
    
    @ObservedObject
    var emitter: SRCoordinatorEmitter
    
    @Environment(\.dismiss) private var dismiss
    
    private let content: () -> Content
    
    public init(context: SRContext,
                coordinator: Coordinator,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.coordinator = coordinator
        self.context = context
        self.emitter = coordinator.emitter
    }
    
    public var body: some View {
        content()
            .onChange(of: emitter.dismissEmitter, perform: { _ in
                coordinator.rootRouter.dismiss()
            })
            .onAppear {
                context.registerActiveCoordinator(coordinator)
            }
            .onDisappear(perform: {
                context.resignActiveCoordinator(identifier: coordinator.identifier)
            })
            .onRouting(of: coordinator.rootRouter)
            .environmentObject(context)
            .environmentObject(coordinator.emitter)
    }
}
