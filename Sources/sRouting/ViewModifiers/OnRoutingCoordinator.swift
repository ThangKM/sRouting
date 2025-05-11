//
//  OnRoutingCoordinator.swift
//  sRouting
//
//  Created by Thang Kieu on 3/5/25.
//

import SwiftUI

struct OnRoutingCoordinator<Route>: ViewModifier where Route: SRRoute {
    
    @State private var  router: SRRouter<Route>
    private let context: SRContext
    private let coordinatorEmitter: SRCoordinatorEmitter
    
    init(_ routeType: Route.Type, emitter: SRCoordinatorEmitter, context: SRContext) {
        self._router = .init(initialValue: .init(routeType))
        self.context = context
        self.coordinatorEmitter = emitter
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: coordinatorEmitter.coordinatorRoute, { oldValue, newValue in
                guard let coordinatorRoute = newValue else { return }
                openCoordinator(coordinatorRoute)
            })
            .onRouting(of: router)
            .environment(context)
    }
    
    private func openCoordinator(_ coordiantor: CoordinatorRoute) {
        Task { @MainActor in
            guard let route = coordiantor.route as? Route else {
                assertionFailure("Coordinator Route must be type of \(Route.self)")
                return
            }
            router.trigger(to: route, with: coordiantor.triggerKind)
        }
    }
}

extension View {
    
    public func onRoutingCoordinator<Route>(_ routeType: Route.Type, emitter: SRCoordinatorEmitter, context: SRContext)
    -> some View where Route: SRRoute {
        modifier(OnRoutingCoordinator(routeType, emitter: emitter, context: context))
    }
}
