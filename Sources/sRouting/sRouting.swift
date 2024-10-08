

/// A screen's router that can navigate to other screen of route.
///
/// The router can trigger a transition from anywhere.
@attached(member, names: named(transition), arbitrary)
@attached(extension, conformances: SRRouterType)
public macro sRouter<T: SRRoute>(_ route: T.Type) = #externalMacro(module: "sRoutingMacros", type: "RouterMacro")

/// Create a context that includes coordinators of navigation
@attached(member, names: arbitrary)
@attached(peer, names: named(SRRootRoute), named(SRNavStack), named(SRTabItem), named(SRRootRouter))
@attached(extension, conformances: SRContextType)
public macro sRContext(tabs: [String] = [], stacks: String...) = #externalMacro(module: "sRoutingMacros", type: "ContextMacro")

/// Generate a view of navigation destinations that observing routes
@attached(member, names: named(path), named(content), arbitrary)
@attached(extension, conformances: SRObserveViewType)
public macro sRouteObserve(_ routes: (any SRRoute.Type)...) = #externalMacro(module: "sRoutingMacros", type: "RouteObserveMacro")
