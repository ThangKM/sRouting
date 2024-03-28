//
//  NavigatorView.swift
//  sRouting
//
//  Created by ThangKieu on 2/19/21.
//

import SwiftUI

/// The hidden view that handle the navigation of a screen.
@MainActor
struct NavigatorView<RouterType>: View where RouterType: SRRouterType  {
    
    typealias VoidAction = () -> Void
    typealias RouteType = RouterType.RouteType
    
    /// A  screen's ``Router``
    private var router: RouterType

    @Environment(SRTabarSelection.self)
    private var tabarSelection: SRTabarSelection?
    
    @Environment(SRNavigationPath.self)
    private var navigationPath: SRNavigationPath?
    
    @Environment(SRDismisAllEmitter.self)
    private var dismissAllEmitter: SRDismisAllEmitter?
    
    @Environment(\.scenePhase) private var scenePhase
    
    /// Active state of a full screen presentation
    @State private(set) var isActivePresent: Bool = false
    /// Active state of a sheet presentation
    @State private(set) var isActiveSheet: Bool = false
    /// Active state of a alert
    @State private(set) var isActiveAlert: Bool = false
    /// Active state of action sheet
    @State private(set) var isActiveActionSheet: Bool = false

    /// Dismiss action of presentationMode from @Enviroment
    private let dismissAction: VoidAction
    
    /// The destination screen from transition
    @ViewBuilder @MainActor
    private var destinationView: some View {
        router.transition.route?.screen
    }
    /// The alert from transition
    private let alertView: Alert?
    
    ///Action test holder
    private let tests: UnitTestActions<Self>?
    
    #if os(iOS) || os(tvOS)
    /// The ActionSheet from transaction
    private var actionSheet: ActionSheet?
    
    init(router: RouterType,
         onDismiss: @escaping VoidAction,
         testsActions: UnitTestActions<Self>? = nil) {
        self.router = router
        self.dismissAction = onDismiss
        self.alertView = router.transition.alert
        self.actionSheet = router.transition.actionSheet
        // test action holder
        self.tests = testsActions
        //
    }
    
    #else
    init(router: RouterType,
         onDismiss: @escaping VoidAction,
         testsActions: UnitTestActions<Self>? = nil) {
        self.router = router
        self.dismissAction = onDismiss
        self.alertView = router.transition.alert
        // test action holder
        self.tests = testsActions
        //
    }
    #endif
    
    #if os(macOS)
    var body: some View {
        Text("Navigator View")
        .sheet(isPresented: $isActiveSheet,
               content: {
            destinationView
                .environment(tabarSelection)
        })
        .alert(isPresented: $isActiveAlert) {
            guard let alert = alertView
            else { return Alert(title: Text("Something went wrong!")) }
            return alert
        }
        .onChange(of: dismissAllEmitter?.dismissAllSignal, { oldValue, newValue in
            resetActiveState()
        })
        .onChange(of: router.transition, { oldValue, newValue in
            updateActiveState(from: newValue)
        })
        .onAppear {
            // test - action
            tests?.didAppear?(self)
            //
        }
        .hidden()
    }
    #else
    var body: some View {
        Text("Navigator View")
        .fullScreenCover(isPresented: $isActivePresent) {
            SRNavigationStack {
                destinationView
            }
            .environment(dismissAllEmitter)
            .environment(tabarSelection)
        }
        .sheet(isPresented: $isActiveSheet,
            content: {
            SRNavigationStack {
                destinationView
            }
            .environment(dismissAllEmitter)
            .environment(tabarSelection)
        })
        .alert(isPresented: $isActiveAlert) {
            guard let alert = alertView
            else { return Alert(title: Text("Something went wrong!")) }
            return alert
        }
        .actionSheet(isPresented: $isActiveActionSheet, content: {
            ActionSheet(title: Text(""))
        })
        .onChange(of: dismissAllEmitter?.dismissAllSignal, { oldValue, newValue in
            resetActiveState()
        })
        .onChange(of: router.transition, { oldValue, newValue in
            updateActiveState(from: newValue)
        })
        .onAppear {
            //test - action
            tests?.didAppear?(self)
            //
        }
        .hidden()
    }
    #endif
}

extension NavigatorView {
    
    /// Reset all active state to false
    @MainActor
    private func resetActiveState() {
        guard scenePhase == .active || tests != nil else { return }
        isActivePresent = false
        isActiveAlert = false
        isActiveSheet = false
        isActiveActionSheet = false
        // test - action
        tests?.resetActiveState?(self)
        //
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
            tabarSelection?.tabSelection = transition.tabIndex ?? 0
        case .dismissAll:
            dismissAllEmitter?.dismissAll()
        case .pop:
            navigationPath?.pop()
        case .popToRoot:
            navigationPath?.popToRoot()
        case .popToRoute:
            guard let route = transition.popToRoute else { return }
            navigationPath?.pop(to: route)
        case .none: break
        }
        // test - action
        tests?.didChangeTransition?(self)
        //
    }
}
