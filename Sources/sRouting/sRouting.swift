
import Foundation

/// Create a coordinator that includes navigations, selections...
@attached(member, names: arbitrary)
@attached(extension, conformances: SRRouteCoordinatorType, names: named(SRRootRoute), named(SRNavStack), named(SRTabItem), named(SRRootRouter))
public macro sRouteCoordinator(tabs: [String] = [], stacks: String...) = #externalMacro(module: "sRoutingMacros", type: "RouteCoordinatorMacro")

/// Generate a `ViewModifier` of navigation destinations that observing routes
@attached(member, names: named(path), arbitrary)
@attached(extension, conformances: SRRouteObserverType)
public macro sRouteObserver(_ routes: (any SRRoute.Type)...) = #externalMacro(module: "sRoutingMacros", type: "RouteObserverMacro")


/// Generate Paths for ``SRRoute``
@attached(extension, conformances: SRRoute, names: named(PathsType), named(Paths), named(path), arbitrary)
public macro sRoute() = #externalMacro(module: "sRoutingMacros", type: "RouteMacro")

/// Indicates a subroute within a route.
@attached(peer)
public macro sSubRoute() = #externalMacro(module: "sRoutingMacros", type: "SubRouteMacro")
