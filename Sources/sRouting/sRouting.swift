


/// A screen's router that can navigate to other screen of route.
///
/// The router can trigger a transition from inside(view) or outside(view model) the view.
@attached(member, names: named(transition), arbitrary)
@attached(extension, conformances: SRRouterType)
public macro sRouter<T: SRRoute>(_ route: T.Type) = #externalMacro(module: "sRoutingMacros", type: "RouterMacro")
