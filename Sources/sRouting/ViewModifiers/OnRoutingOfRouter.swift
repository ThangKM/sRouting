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
    @ObservedObject
    private var router: SRRouter<Route>

    @EnvironmentObject
    private var tabbarSelection: SRTabbarSelection
    
    @EnvironmentObject
    private var navigationPath: SRNavigationPath
    
    @EnvironmentObject
    private var dismissAllEmitter: SRDismissAllEmitter
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismissAction
    #if os(macOS)
    @Environment(\.openDocument) private var openDocument
    #endif
    
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
            .onReceive(dismissAllEmitter.$dismissAllSignal, perform: { _ in
                resetActiveState()
            })
            .onReceive(router.$transition, perform: { newValue in
                let transaction = newValue.transaction?()
                if let transaction {
                    withTransaction(transaction) {
                        updateActiveState(from: newValue)
                    }
                } else {
                    updateActiveState(from: newValue)
                }
            })
            #if DEBUG
            .task {
                assert(_tabbarSelection.presence, "Missing setup `SRRootView` from view hierarchy!")
                assert(_dismissAllEmitter.presence, "Missing setup `SRRootView` from view hierarchy!")
            }
            #endif
        #else
        content
            .fullScreenCover(isPresented: $isActivePresent) {
                destinationView
                .environmentObject(dismissAllEmitter)
                .environmentObject(tabbarSelection)
            }
            .sheet(isPresented: $isActiveSheet,
                content: {
                destinationView
                .environmentObject(dismissAllEmitter)
                .environmentObject(tabbarSelection)
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
            .onReceive(dismissAllEmitter.$dismissAllSignal, perform: { _ in
                resetActiveState()
            })
            .onReceive(router.$transition, perform: { newValue in
                let transaction = newValue.transaction?()
                if let transaction {
                    withTransaction(transaction) {
                        updateActiveState(from: newValue)
                    }
                } else {
                    updateActiveState(from: newValue)
                }
            })
            #if DEBUG
            .task {
                assert(_tabbarSelection.presence, "Missing setup `SRRootView` from view hierarchy!")
                assert(_dismissAllEmitter.presence, "Missing setup `SRRootView` from view hierarchy!")
            }
            #endif
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
            guard let route = transition.route, _navigationPath.presence else { break }
            navigationPath.push(to: route)
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
            tabbarSelection.select(tag: transition.tabIndex ?? .zero)
        case .dismissAll:
            dismissAllEmitter.dismissAll()
        case .dismissCoordinator:
            dismissAllEmitter.dismissCoordinator()
        case .pop:
            guard _navigationPath.presence else { break }
            navigationPath.pop()
        case .popToRoot:
            guard _navigationPath.presence else { break }
            navigationPath.popToRoot()
        case .popToRoute:
            guard let route = transition.popToRoute, _navigationPath.presence else { break }
            navigationPath.pop(to: route)
        case .openWindow:
            openWindow(transition: transition.windowTransition)
        case .openURL:
            openURL(from: transition.windowTransition)
        #if os(macOS)
        case .openDocument:
            openDoc(transition: transition.windowTransition)
        #endif
                    
        case .none: break
        }
        
        tests?.didChangeTransition?(self)
    }
    
    #if os(macOS)
    @MainActor
    private func openDoc(transition: SRWindowTransition?) {
        guard let transition,
              let url = transition.url
        else { return }
        
        guard tests == nil else {
            tests?.didOpenDoc?(url)
            return
        }
        
        Task {
            do {
                try await openDocument(at: url)
                transition.errorHandler?(.none)
            } catch {
                transition.errorHandler?(error)
            }
        }
    }
    #endif
    
    @MainActor
    private func openURL(from transition: SRWindowTransition?) {
        guard let windowTransition = transition,
              let url = windowTransition.url
        else { return }
        
        guard tests == nil else {
            tests?.didOpenURL?(url)
            return
        }
        
        if let acception = windowTransition.acception {
            openURL(url, completion: acception)
        } else {
            openURL(url)
        }
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


extension EnvironmentObject {
    var presence: Bool {
        !String(describing: self).contains("_store: nil")
    }
}
