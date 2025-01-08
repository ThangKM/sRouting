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
    @State private(set) var isActiveActionSheet: Bool = false

    /// The destination screen from transition
    @MainActor
    private var destinationView: some View {
        router.transition.route?.screen
    }
    /// The alert from transition
    @MainActor
    private var alertView: Alert? {
        router.transition.alert?()
    }
    
    #if canImport(UIKit)
    /// The ActionSheet from transaction
    @MainActor
    private var actionSheet: ActionSheet? {
        router.transition.actionSheet?()
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
            .alert(isPresented: $isActiveAlert) {
                if let alertView {
                    alertView
                } else {
                    Alert(title: Text("Something went wrong!"))
                }
            }
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
            .alert(isPresented: $isActiveAlert) {
                if let alertView {
                    alertView
                } else {
                    Alert(title: Text("Something went wrong!"))
                }
            }
            .actionSheet(isPresented: $isActiveActionSheet, content: {
               if let actionSheet {
                   actionSheet
               } else {
                   ActionSheet(title: Text("Action Sheet not found!"))
               }
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
        isActiveActionSheet = false
    }
    
    /// Observe the transition change from router
    /// - Parameter transition: ``Transiton``
    @MainActor
    private func updateActiveState(from transition: SRTransition<Route>) {
        switch transition.type {
        case .push:
            guard let route = transition.route else { return }
            navigationPath.push(to: route)
        case .present:
            isActivePresent = true
        case .sheet:
            isActiveSheet = true
        case .alert:
            isActiveAlert = true
        case .actionSheet:
            isActiveActionSheet = true
        case .dismiss:
            dismissAction()
        case .selectTab:
            tabbarSelection.select(tag: transition.tabIndex ?? .zero)
        case .dismissAll:
            dismissAllEmitter.dismissAll()
        case .pop:
            navigationPath.pop()
        case .popToRoot:
            navigationPath.popToRoot()
        case .popToRoute:
            guard let route = transition.popToRoute else { break }
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
