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
    
    public var topCoordinator: SRRouteCoordinatorType? {
        coordinators.last?.coordinator
    }
    
    public init() { }
    
    public func dismissAll() {
        dismissAllSignal.toggle()
    }
}

extension SRContext {
    
    public enum RoutingRoute: SRRoute {
        case resetAll
        case dismissAll
        case popToRoot
        case selectTabView(at: Int)
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
            dismissAll()
            coordinators.forEach { coors in
                coors.coordinator?.navigationStacks.forEach {
                    $0.popToRoot()
                }
            }
        case .dismissAll:
            dismissAll()
        case .popToRoot:
            topCoordinator?.activeNavigation?.popToRoot()
        case .selectTabView(let index):
            topCoordinator?.emitter.select(tag: index)
        case .push(route: let route):
            topCoordinator?.activeNavigation?.push(to: route)
        case .sheet(let route):
            topCoordinator?.rootRouter.trigger(to: AnyRoute(route: route), with: .sheet)
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

//MARK: - Internal Helpers
extension SRContext {
    
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
}

private final class WeakCoordinatorReference {
    weak var coordinator: SRRouteCoordinatorType?
    
    init(coordinator: SRRouteCoordinatorType) {
        self.coordinator = coordinator
    }
}
