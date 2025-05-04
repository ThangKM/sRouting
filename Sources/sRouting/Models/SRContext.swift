//
//  SRContext.swift
//  sRouting
//
//  Created by Thang Kieu on 6/4/25.
//

import Foundation
import SwiftUI

@Observable @MainActor
public final class SRContext: Sendable {
    
    @ObservationIgnored
    private var coordinators: [WeakCoordinatorReference] = []

    private(set) var dismissAllSignal: SignalChange = false
    
    private(set) var coordinatorRoute: CoordinatorRoute?
    
    public var topCoordinator: SRRouteCoordinatorType? {
        coordinators.last?.coordinator
    }
    
    public var coordinatorCount: Int {
        coordinators.count
    }
    
    public init() { }
    
    public func dismissAll() {
        dismissAllSignal.toggle()
    }
    
    public func routing(_ routes: RoutingRoute...,
                        waitDuration duration: Duration = .milliseconds(600)) async {
        let routeStream = AsyncStream { continuation in
            for route in routes {
                continuation.yield(route)
            }
            continuation.finish()
        }
        
        for await route in routeStream {
            await _routing(for: route, duration: max(duration, .milliseconds(400)))
        }
    }
}

extension SRContext {
    
    public enum RoutingRoute: SRRoute {
        case resetAll
        case dismissAll
        case popToRoot
        case selectTabView(any IntRawRepresentable)
        case push(route: any SRRoute)
        case sheet(any SRRoute)
        case window(SRWindowTransition)
        case wait(Duration)
        #if os(iOS)
        case present(any SRRoute)
        #endif

        public var screen: some View {
           fatalError("sRouting.SRRootRoute doesn't have screen")
        }

        public var path: String {
            switch self {
            case .resetAll:
                return "routingRoute.resetall"
            case .dismissAll:
                return "routingRoute.dismissall"
            case .selectTabView(_):
                return "routingRoute.selecttab"
            case .push(let route):
                return "routingRoute.push.\(route.path)"
            case .sheet(let route):
                return "routingRoute.sheet.\(route.path)"
            case .window(let transition):
                if let id = transition.windowId {
                    return "routingRoute.window.\(id)"
                } else if let value = transition.windowValue {
                    return "routingRoute.window.\(value.hashValue)"
                } else {
                    return "routingRoute.window"
                }
            case .popToRoot:
                return "routingRoute.popToRoot"
            case .wait(_):
                return "routingRoute.waiting"
            #if os(iOS)
            case .present(let route):
                return "routingRoute.present.\(route.path)"
            #endif
            }
        }
    }

    private func _routing(for route: RoutingRoute, duration: Duration) async {
        
        switch route {
        case .resetAll:
            resetAll()
        case .dismissAll:
            dismissAll()
        case .popToRoot:
            topCoordinator?.activeNavigation?.popToRoot()
        case .selectTabView(let tab):
            topCoordinator?.emitter.select(tag: tab.intValue)
        case .push(route: let route):
            topCoordinator?.activeNavigation?.push(to: route)
        case .sheet(let route):
            topCoordinator?.rootRouter.trigger(to: .init(route: route), with: .sheet)
        case .window(let windowTrans):
            topCoordinator?.rootRouter.openWindow(windowTrans: windowTrans)
        case .wait(let duration):
            try? await Task.sleep(for: duration)
        #if os(iOS)
        case .present(let route):
            topCoordinator?.rootRouter.trigger(to: .init(route: route), with: .present)
        #endif
        }
        
        guard route.path != RoutingRoute.wait(.zero).path else { return }
        try? await Task.sleep(for: duration)
    }
}

//MARK: - Coordinators Handling
extension SRContext {
    
    internal func openCoordinator(_ coordinatorRoute: CoordinatorRoute) {
        assert(coordinatorRoute.triggerKind != .push, "Open a new coordinator not allowed for push trigger")
        guard coordinatorRoute.triggerKind != .push else { return }
        guard coordinatorRoute != self.coordinatorRoute else { return }
        self.coordinatorRoute = coordinatorRoute
    }
    
    internal func registerActiveCoordinator(_ coordinator: SRRouteCoordinatorType) {
        cleanCoordinates()
        guard coordinators.contains(where: { $0.coordinator?.identifier == coordinator.identifier }) == false else { return }
        coordinators.append(.init(coordinator: coordinator))
    }
    
    internal func resignActiveCoordinator(identifier: String) {
        guard !coordinators.isEmpty else { return }
        cleanCoordinates()
        coordinators.removeAll(where: { $0.coordinator?.identifier == identifier })
    }
    
    private func cleanCoordinates() {
        guard !coordinators.isEmpty else { return }
        coordinators.removeAll(where: { $0.coordinator == nil })
    }
    
    internal func resetAll() {
        dismissAll()
        coordinators.forEach { coors in
            coors.coordinator?.navigationStacks.forEach {
                $0.popToRoot()
            }
        }
    }
}

//MARK: - Helpers
private final class WeakCoordinatorReference {
    weak var coordinator: SRRouteCoordinatorType?
    
    init(coordinator: SRRouteCoordinatorType) {
        self.coordinator = coordinator
    }
}
