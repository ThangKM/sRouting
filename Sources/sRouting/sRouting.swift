

/// Create a context that includes the root coordinator of navigations
@attached(member, names: arbitrary)
@attached(peer, names: named(SRRootRoute), named(SRNavStack), named(SRTabItem), named(SRRootRouter))
@attached(extension, conformances: SRRouteCoordinatorType)
public macro sRouteCoordinator(tabs: [String] = [], stacks: String...) = #externalMacro(module: "sRoutingMacros", type: "RouteCoordinatorMacro")

/// Generate a `ViewModifier` of navigation destinations that observing routes
@attached(member, names: named(path), arbitrary)
@attached(extension, conformances: SRRouteObserverType)
public macro sRouteObserver(_ routes: (any SRRoute.Type)...) = #externalMacro(module: "sRoutingMacros", type: "RouteObserverMacro")
