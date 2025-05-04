//
//  CoordinatorRoute.swift
//  sRouting
//
//  Created by Thang Kieu on 3/5/25.
//

struct CoordinatorRoute {
    
    let route: any SRRoute
    let triggerKind: SRTriggerType
    let identifier: TimeIdentifier
    
    init(route: some SRRoute, triggerKind: SRTriggerType) {
        self.route = route
        self.triggerKind = triggerKind
        self.identifier = TimeIdentifier()
    }
}

extension CoordinatorRoute: Hashable {
    
    static func == (lhs: CoordinatorRoute, rhs: CoordinatorRoute) -> Bool {
        lhs.route.path == rhs.route.path && lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(route.path)
        hasher.combine(identifier)
    }
}
