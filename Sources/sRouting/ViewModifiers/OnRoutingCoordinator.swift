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
    
    init(_ routeType: Route.Type, context: SRContext) {
        self._router = .init(initialValue: .init(routeType))
        self.context = context
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: context.coordinatorRoute, { oldValue, newValue in
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
    
    public func onRoutingCoordinator<Route>(_ routeType: Route.Type, context: SRContext)
    -> some View where Route: SRRoute {
        modifier(OnRoutingCoordinator(routeType, context: context))
    }
}
