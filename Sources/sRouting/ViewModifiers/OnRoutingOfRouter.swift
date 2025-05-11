//
//  OnRoutingOfRouter.swift
//  sRouting
//
//  Created by Thang Kieu on 23/9/24.
//

import SwiftUI

struct RouterModifier<Route>: ViewModifier where Route: SRRoute {
    
    typealias VoidAction = () -> Void

    /// A  screen's ``Router``
    private let router: SRRouter<Route>

    @Environment(SRCoordinatorEmitter.self)
    private var coordinatorEmitter: SRCoordinatorEmitter?
    
    @Environment(SRNavigationPath.self)
    private var navigationPath: SRNavigationPath?
    
    @Environment(SRContext.self)
    private var context: SRContext?
    
    @Environment(SwitcherBox.self)
    private var switcher: SwitcherBox?
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismissAction

    /// Active state of a full screen presentation
    @State private(set) var isActivePresent: Bool = false
    /// Active state of a sheet presentation
    @State private(set) var isActiveSheet: Bool = false
    /// Active state of a alert
    @State private(set) var isActiveAlert: Bool = false
    /// Active state of action sheet
    @State private(set) var isActiveDialog: Bool = false
    /// Active state of popover
    @State private(set) var isActivePopover: Bool = false
    
    /// The destination screen from transition
    @MainActor
    private var destinationView: some View {
        router.transition.route?.screen
    }

    @MainActor
    private var alertTitle: LocalizedStringKey {
        router.transition.alert?.titleKey ?? ""
    }
    
    @MainActor
    private var alertActions: some View {
        router.transition.alert?.actions
    }
    
    @MainActor
    private var alertMessage: some View {
        router.transition.alert?.message
    }
    
    @MainActor
    private var dialogTitleKey: LocalizedStringKey {
        router.transition.confirmationDialog?.titleKey ?? ""
    }
    
    @MainActor
    private var dialogTitleVisibility: Visibility {
        router.transition.confirmationDialog?.titleVisibility ?? .hidden
    }
    
    @MainActor
    private var dialogActions: some View {
        router.transition.confirmationDialog?.actions
    }
    
    @MainActor
    private var dialogMessage: some View {
        router.transition.confirmationDialog?.message
    }

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
    
    ///Action test holder
    private let tests: UnitTestActions<Self>?
    
    init(router: SRRouter<Route>, tests: UnitTestActions<Self>? = .none) {
        self.router = router
        self.tests = tests
    }
    
    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .sheet(isPresented: $isActiveSheet,
                   content: {
                destinationView
                    .environment(context)
            })
            .alert(alertTitle, isPresented: $isActiveAlert, actions: {
                alertActions
            }, message: {
                alertMessage
            })
            .confirmationDialog(dialogTitleKey,
                                isPresented: $isActiveDialog,
                                titleVisibility: dialogTitleVisibility,
                                actions: {
                dialogActions
            }, message: {
                dialogMessage
            })
            .onChange(of: context?.dismissAllSignal, { oldValue, newValue in
                resetActiveState()
            })
            .onChange(of: coordinatorEmitter?.dismissEmitter, { oldValue, newValue in
                dismissCoordinator()
            })
            .onChange(of: router.transition, { oldValue, newValue in
                let transaction = newValue.transaction?()
                if let transaction {
                    withTransaction(transaction) {
                        updateActiveState(from: newValue)
                    }
                } else {
                    updateActiveState(from: newValue)
                }
            })
            .onChange(of: isActiveAlert, { oldValue, newValue in
                guard oldValue && !newValue else { return }
                resetRouterTransiton()
            })
            .onChange(of: isActiveSheet, { oldValue, newValue in
                guard oldValue && !newValue else { return }
                resetRouterTransiton()
            })
            .onChange(of: isActiveDialog, { oldValue, newValue in
                guard oldValue && !newValue else { return }
                resetRouterTransiton()
            })
            .onAppear() {
                resetRouterTransiton()
            }
        #else
        content
            .fullScreenCover(isPresented: $isActivePresent) {
                destinationView
                    .environment(context)
            }
            .sheet(isPresented: $isActiveSheet,
                content: {
                destinationView
                    .environment(context)
            })
            .alert(alertTitle, isPresented: $isActiveAlert, actions: {
                alertActions
            }, message: {
                alertMessage
            })
            .confirmationDialog(dialogTitleKey,
                                isPresented: $isActiveDialog,
                                titleVisibility: dialogTitleVisibility,
                                actions: {
                dialogActions
            }, message: {
                dialogMessage
            })
            .popover(isPresented: $isActivePopover,
                     attachmentAnchor: popoverAnchor,
                     arrowEdge: popoverEdge,
                     content: {
                popoverContent
                    .environment(context)
            })
            .onChange(of: context?.dismissAllSignal, { oldValue, newValue in
                resetActiveState()
            })
            .onChange(of: coordinatorEmitter?.dismissEmitter, { oldValue, newValue in
                dismissCoordinator()
            })
            .onChange(of: router.transition, { oldValue, newValue in
                let transaction = newValue.transaction?()
                if let transaction {
                    withTransaction(transaction) {
                        updateActiveState(from: newValue)
                    }
                } else {
                    updateActiveState(from: newValue)
                }
            })
            .onChange(of: isActiveAlert, { oldValue, newValue in
                guard oldValue && !newValue else { return }
                resetRouterTransiton()
            })
            .onChange(of: isActiveSheet, { oldValue, newValue in
                guard oldValue && !newValue else { return }
                resetRouterTransiton()
            })
            .onChange(of: isActiveDialog, { oldValue, newValue in
                guard oldValue && !newValue else { return }
                resetRouterTransiton()
            })
            .onChange(of: isActivePresent, { oldValue, newValue in
                guard oldValue && !newValue else { return }
                resetRouterTransiton()
            })
            .onChange(of: isActivePopover, { oldValue, newValue in
                guard oldValue && !newValue else { return }
                resetRouterTransiton()
            })
            .onAppear() {
                resetRouterTransiton()
            }
        #endif
    }
}

extension RouterModifier {
    
    @MainActor
    private func resetRouterTransiton() {
        guard scenePhase != .background || tests != nil else { return }
        router.resetTransition()
    }
    
    @MainActor
    private func dismissCoordinator() {
        resetActiveState()
        guard let context, context.topCoordinator?.emitter === coordinatorEmitter && context.coordinatorCount > 1 else { return }
        dismissAction()
    }
    
    /// Reset all active state to false
    @MainActor
    func resetActiveState() {
        guard scenePhase != .background || tests != nil else { return }
        isActivePresent = false
        isActiveAlert = false
        isActiveSheet = false
        isActiveDialog = false
        isActivePopover = false
    }
    
    /// Observe the transition change from router
    /// - Parameter transition: ``Transiton``
    @MainActor
    private func updateActiveState(from transition: SRTransition<Route>) {
        switch transition.type {
        case .push:
            guard let route = transition.route else { break }
            navigationPath?.push(to: route)
        case .present:
            isActivePresent = true
        case .sheet:
            isActiveSheet = true
        case .alert:
            isActiveAlert = true
        case .confirmationDialog:
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                break
            } else {
                isActiveDialog = true
            }
            #else
            isActiveDialog = true
            #endif
        case .popover:
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                break
            } else {
                isActivePopover = true
            }
            #else
            break
            #endif
        case .dismiss:
            dismissAction()
        case .selectTab:
            coordinatorEmitter?.select(tag: transition.tabIndex?.intValue ?? .zero)
        case .dismissAll:
            context?.dismissAll()
        case .dismissCoordinator:
            coordinatorEmitter?.dismiss()
        case .pop:
            navigationPath?.pop()
        case .popToRoot:
            navigationPath?.popToRoot()
        case .popToRoute:
            guard let path = transition.popToPath else { break }
            navigationPath?.pop(to: path)
        case .openWindow:
            openWindow(transition: transition.windowTransition)
        case .switchRoot:
            guard let route = transition.rootRoute else { break }
            switcher?.switchTo(route: route)
        case .openCoordinator:
            guard let coordinatorRoute = transition.coordinator else { break }
            coordinatorEmitter?.openCoordinator(coordinatorRoute)
        case .none: break
        }
        
        tests?.didChangeTransition?(self)
    }
    
    @MainActor
    private func openWindow(transition: SRWindowTransition?) {
        guard let transition else { return }
        guard tests == nil else {
            tests?.didOpenWindow?(transition)
            return
        }
        
        switch (transition.windowId, transition.windowValue) {
        case (.some(let id), .none):
            openWindow(id: id)
        case (.none, .some(let value)):
            openWindow(value: value)
        case (.some(let id), .some(let value)):
            openWindow(id: id, value: value)
        case (.none, .none):
            break
        }
    }
}

extension View {
    
    /// Observe router transitions
    /// - Parameter router: ``SRRouterType``
    /// - Returns: some `View`
    public func onRouting<Route: SRRoute>(of router: SRRouter<Route>) -> some View {
        self.modifier(RouterModifier(router: router))
    }
    
    /// Observe router transition (on test purpose)
    /// - Parameters:
    ///   - router: ``SRRouterType``
    ///   - tests: Unit test action
    /// - Returns: some `View`
    func onRouting<Route: SRRoute>(of router: SRRouter<Route>,
                                   tests: UnitTestActions<RouterModifier<Route>>?) -> some View {
        self.modifier(RouterModifier(router: router, tests: tests))
    }
}
