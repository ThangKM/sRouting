


/// A screen's router that can navigate to other screen of route.
///
/// The router can trigger a transition from anywhere.
@attached(member, names: named(transition), arbitrary)
@attached(extension, conformances: SRRouterType)
public macro sRouter<T: SRRoute>(_ route: T.Type) = #externalMacro(module: "sRoutingMacros", type: "RouterMacro")


@attached(member, names: arbitrary)
@attached(peer, names: named(SRRootRoute), named(SRNavStacks), named(SRTabItems), named(SRRootRouter))
@attached(extension, conformances: SRContextType)
public macro sRContext(tabs: [String] = [], stacks: String...) = #externalMacro(module: "sRoutingMacros", type: "ContextMacro")
