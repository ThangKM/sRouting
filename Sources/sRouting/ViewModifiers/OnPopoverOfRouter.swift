//
//  OnPopoverOfRouter.swift
//  sRouting
//
//  Created by Thang Kieu on 23/3/25.
//

import SwiftUI

struct OnPopoverOfRouter<Route>: ViewModifier where Route: SRRoute {
    
    private let popoverRoute: Route.PopoverRoute
    
    @ObservedObject
    private var router: SRRouter<Route>
    
    @Environment(\.scenePhase) private var scenePhase
    
    ///Action test holder
    private let tests: UnitTestActions<Self>?
    
    /// Active state of popover
    @State private(set) var isActivePopover: Bool = false
  
    @MainActor
    private var popoverAnchor: PopoverAttachmentAnchor {
        router.transition.popover?.attachmentAnchor ?? .rect(.bounds)
    }
    
    @MainActor
    private var popoverEdge: Edge? {
        router.transition.popover?.arrowEdge
    }
    
    @MainActor
    private var popoverContent: some View {
        router.transition.popover?.content
    }
    
    init(router: SRRouter<Route>, popover: Route.PopoverRoute, tests: UnitTestActions<Self>? = nil) {
        self.router = router
        self.popoverRoute = popover
        self.tests = tests
    }
    
    func body(content: Content) -> some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            main(content: content)
        } else {
            content
        }
        #else
        main(content: content)
        #endif
    }
    
    @ViewBuilder
    private func main(content: Content) -> some View {
        content
        .popover(isPresented: $isActivePopover,
                 attachmentAnchor: popoverAnchor,
                 arrowEdge: popoverEdge,
                 content: {
            popoverContent
        })
        .onChange(of: router.transition, perform: { newValue in
            #if os(iOS)
            guard newValue.type == .popover
                    && UIDevice.current.userInterfaceIdiom == .pad
                    && newValue.popover == popoverRoute else { return }
            isActivePopover = true
            tests?.didChangeTransition?(self)
            #else
            guard newValue.type == .popover
                    && newValue.popover == popoverRoute else { return }
            isActivePopover = true
            tests?.didChangeTransition?(self)
            #endif
        })
        .onChange(of: isActivePopover, perform: { newValue in
            guard !newValue else { return }
            resetRouterTransiton()
        })
    }
}
 
extension OnPopoverOfRouter {
    /// Reset all active state to false
    @MainActor
    func resetActiveState() {
        guard scenePhase != .background || tests != nil else { return }
        isActivePopover = false
    }
    
    @MainActor
    private func resetRouterTransiton() {
        guard scenePhase != .background || tests != nil else { return }
        router.resetTransition()
    }
}

extension View {
    
    /// Show Popover on iPad at the anchor view.
    /// - Parameters:
    ///   - router: ``SRRouter``
    ///   - popover: ``SRPopoverRoute``
    /// - Returns: `some View`
    public func onPopoverRouting<Route: SRRoute>(of router: SRRouter<Route>, for popover: Route.PopoverRoute) -> some View {
        self.modifier(OnPopoverOfRouter(router: router, popover: popover))
    }
    
    
    /// Show Popover on iPad at the anchor view (on test purpose).
    /// - Parameters:
    ///   - router: ``SRRouter``
    ///   - popover: ``SRPopoverRoute``
    /// - Returns: `some View`
    func onPopoverRouting<Route: SRRoute>(of router: SRRouter<Route>,
                                          for popover: Route.PopoverRoute,
                                          tests: UnitTestActions<OnPopoverOfRouter<Route>>?) -> some View {
        self.modifier(OnPopoverOfRouter(router: router, popover: popover, tests: tests))
    }
}
