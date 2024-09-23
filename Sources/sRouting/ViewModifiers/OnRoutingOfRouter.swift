//
//  OnRoutingOfRouter.swift
//  sRouting
//
//  Created by Thang Kieu on 23/9/24.
//

import SwiftUI

struct RouterModifier<Router>: ViewModifier where Router: SRRouterType {
    
    typealias VoidAction = () -> Void
    typealias RouteType = Router.RouteType
    
    /// A  screen's ``Router``
    private let router: Router

    @Environment(SRTabbarSelection.self)
    private var tabbarSelection: SRTabbarSelection?
    
    @Environment(SRNavigationPath.self)
    private var navigationPath: SRNavigationPath?
    
    @Environment(SRDismissAllEmitter.self)
    private var dismissAllEmitter: SRDismissAllEmitter?
    
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
    @ViewBuilder @MainActor
    private var destinationView: some View {
        router.transition.route?.screen
    }
    /// The alert from transition
    @MainActor
    private var alertView: Alert? {
        router.transition.alert?.value
    }
    
    #if canImport(UIKit)
    /// The ActionSheet from transaction
    @MainActor
    private var actionSheet: ActionSheet? {
        router.transition.actionSheet?.value
    }
    #endif
    
    ///Action test holder
    private let tests: UnitTestActions<Self>?
    
    init(router: Router, tests: UnitTestActions<Self>? = .none) {
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
            .onChange(of: dismissAllEmitter?.dismissAllSignal, { oldValue, newValue in
                resetActiveState()
            })
            .onChange(of: router.transition, { oldValue, newValue in
                updateActiveState(from: newValue)
            })
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
            .onChange(of: dismissAllEmitter?.dismissAllSignal, { oldValue, newValue in
                resetActiveState()
            })
            .onChange(of: router.transition, { oldValue, newValue in
                updateActiveState(from: newValue)
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
    private func updateActiveState(from transition: SRTransition<RouteType>) {
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
        case .actionSheet:
            isActiveActionSheet = true
        case .dismiss:
            dismissAction()
        case .selectTab:
            tabbarSelection?.select(tag: transition.tabIndex ?? .zero)
        case .dismissAll:
            dismissAllEmitter?.dismissAll()
        case .pop:
            navigationPath?.pop()
        case .popToRoot:
            navigationPath?.popToRoot()
        case .popToRoute:
            guard let route = transition.popToRoute else { break }
            navigationPath?.pop(to: route)
        case .openWindow:
            openWindow(transition: transition.windowTransition)
        case .openURL:
            guard let windowTransition = transition.windowTransition,
                  let url = windowTransition.url
            else { break }
            if let acception = windowTransition.acception {
                openURL(url, completion: acception)
            } else {
                openURL(url)
            }
        #if os(macOS)
        case .openDocument:
            guard let windowTransition = transition.windowTransition,
                  let url = windowTransition.url
            else { break }
            Task {
                await openDoc(at:url, errorHandler:windowTransition.errorHandler)
            }
        #endif
                    
        case .none: break
        }
        
        tests?.didChangeTransition?(self)
    }
    
    #if os(macOS)
    @MainActor
    private func openDoc(at url: URL, errorHandler: ((Error?) -> Void)?) async {
        do {
            try await openDocument(at: url)
            errorHandler?(.none)
        } catch {
            errorHandler?(error)
        }
    }
    #endif
    
    @MainActor
    private func openWindow(transition: SRWindowTransition?) {
        guard let transition else { return }
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
    
    /// Observe Dismiss all change
    /// - Parameter onChange: action
    /// - Returns: some `View`
    public func onRouting<Router: SRRouterType>(of router: Router) -> some View {
        self.modifier(RouterModifier(router: router))
    }
    
    /// Observe Dismiss all change on test purpose
    /// - Parameters:
    ///   - router: onChange: action
    ///   - tests: Unit test action
    /// - Returns: some `View`
    func onRouting<Router: SRRouterType>(of router: Router,
                                         tests: UnitTestActions<RouterModifier<Router>>?) -> some View {
        self.modifier(RouterModifier(router: router, tests: tests))
    }
}
