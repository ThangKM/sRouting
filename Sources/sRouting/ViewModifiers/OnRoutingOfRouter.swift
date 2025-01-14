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

    @Environment(SRTabbarSelection.self)
    private var tabbarSelection: SRTabbarSelection?
    
    @Environment(SRNavigationPath.self)
    private var navigationPath: SRNavigationPath?
    
    @Environment(SRDismissAllEmitter.self)
    private var dismissAllEmitter: SRDismissAllEmitter?
    
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
    
    #if os(iOS) || os(tvOS)
    /// The ActionSheet from transaction
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
    #endif
    
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
            })
            .alert(alertTitle, isPresented: $isActiveAlert, actions: {
                alertActions
            }, message: {
                alertMessage
            })
            .onChange(of: dismissAllEmitter?.dismissAllSignal, { oldValue, newValue in
                resetActiveState()
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
            .onAppear() {
                router.resetTransition()
            }
        #else
        content
            .fullScreenCover(isPresented: $isActivePresent) {
                destinationView
                .environment(dismissAllEmitter)
                .environment(tabbarSelection)
            }
            .sheet(isPresented: $isActiveSheet,
                content: {
                destinationView
                .environment(dismissAllEmitter)
                .environment(tabbarSelection)
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
            .onChange(of: dismissAllEmitter?.dismissAllSignal, { oldValue, newValue in
                resetActiveState()
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
            .onAppear() {
                router.resetTransition()
            }
        #endif
    }
}

extension RouterModifier {
    
    /// Reset all active state to false
    @MainActor
    private func resetActiveState() {
        guard scenePhase == .active else { return }
        isActivePresent = false
        isActiveAlert = false
        isActiveSheet = false
        isActiveDialog = false
    }
    
    /// Observe the transition change from router
    /// - Parameter transition: ``Transiton``
    @MainActor
    private func updateActiveState(from transition: SRTransition<Route>) {
        switch transition.type {
        case .push:
            guard let route = transition.route else { return }
            navigationPath?.push(to: route)
        case .present:
            isActivePresent = true
        case .sheet:
            isActiveSheet = true
        case .alert:
            isActiveAlert = true
        case .confirmationDialog:
            isActiveDialog = true
        case .dismiss:
            dismissAction()
        case .selectTab:
            tabbarSelection?.select(tag: transition.tabIndex ?? .zero)
        case .dismissAll:
            dismissAllEmitter?.dismissAll()
        case .dismissCoordinator:
            dismissAllEmitter?.dismissCoordinator()
        case .pop:
            navigationPath?.pop()
        case .popToRoot:
            navigationPath?.popToRoot()
        case .popToRoute:
            guard let route = transition.popToRoute else { break }
            navigationPath?.pop(to: route)
        case .openWindow:
            openWindow(transition: transition.windowTransition)
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

#if os(macOS)
extension OpenDocumentAction: @unchecked Sendable { }
#endif

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
