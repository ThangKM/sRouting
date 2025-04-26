//
//  SRSwitcher.swift
//  sRouting
//
//  Created by Thang Kieu on 26/4/25.
//

import Foundation

protocol RouteSwitchable {
    
    associatedtype Route: SRRoute
    
    var route: Route { get }

    func switchTo(route: some SRRoute)
}

@Observable
final class SRSwitcher<Route>: RouteSwitchable where Route: SRRoute {
    
    private(set) var route: Route
    
    init(route: Route) {
        self.route = route
    }
    
    func switchTo(route: some SRRoute) {
        guard let root = route as? Route else {
            assertionFailure("SRSwitcher: Cannot switch route to \(String(describing: route)), must be of type \(String(describing: Route.self))")
            return
        }
        guard root != self.route else {
            return
        }
        self.route = root
    }
}

@Observable
final class SwitcherBox {
    
    let switcher: any RouteSwitchable
    
    init(switcher: some RouteSwitchable) {
        self.switcher = switcher
    }
    
    func switchTo(route: some SRRoute) {
        switcher.switchTo(route: route)
    }
}
