//
//  NavigatorView.swift
//  sRouting
//
//  Created by ThangKieu on 2/19/21.
//

import SwiftUI

/// The hidden view that handle the navigation of a screen.
struct NavigatorView<RouteType>: View
where RouteType: Route {
    
    typealias VoidAction = () -> Void
    
    /// A  screen's ``Router``
    @ObservedObject
    private var router: Router<RouteType>

    /// A `EnvironmentObject` ``RootRouter``
    @EnvironmentObject
    private var rootRouter: RootRouter
    
    @Environment(\.scenePhase) private var scenePhase
    
    /// Active state of a `NavigationLink`
    @State private(set) var isActivePush: Bool = false
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
    @ViewBuilder
    private var destinationView: some View {
        router.transition.route?.screen
    }
    /// The alert from transition
    private let alertView: Alert?
    
    ///Action test holder
    private let tests: UnitTestActions<Self, RouteType>?
    
    #if os(iOS) || os(tvOS)
    /// The ActionSheet from transaction
    private var actionSheet: ActionSheet?
    
    init(router: Router<RouteType>,
         onDismiss: @escaping VoidAction,
         testsActions: UnitTestActions<Self, RouteType>? = nil) {
        self.router = router
        self.dismissAction = onDismiss
        self.alertView = router.transition.alert
        self.actionSheet = router.transition.actionSheet
        // test action holder
        self.tests = testsActions
        //
    }
    
    #else
    init(router: Router<RouteType>,
         onDismiss: @escaping VoidAction,
         testsActions: UnitTestActions<Self, RouteType>? = nil) {
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
        Group {
            NavigationLink(
                destination: destinationView,
                isActive: $isActivePush.willSet(execute: onChangeActiveState(_:)),
                label: {
                    EmptyView()
                })
        }
        .sheet(isPresented: $isActiveSheet.willSet(execute: onChangeActiveState(_:)),
            content: {
            destinationView
                .environmentObject(rootRouter)
        })
        .alert(isPresented: $isActiveAlert.willSet(execute: onChangeActiveState(_:))) {
            guard let alert = alertView
            else { return Alert(title: Text("Something went wrong!")) }
            return alert
        }
        .onChange(of: rootRouter.dismissAll, perform: { _ in
            resetActiveState()
        })
        .onChange(of: router.transition, perform: { (transition) in
            updateActiveState(from: transition)
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
        Group {
            NavigationLink(
                destination: destinationView,
                isActive: $isActivePush.willSet(execute: onChangeActiveState(_:)),
                label: {
                    EmptyView()
                })
        }
        .fullScreenCover(isPresented: $isActivePresent.willSet(execute: onChangeActiveState(_:))) {
            if #available(iOS 15, tvOS 15, *) {
                NavigationView {
                    destinationView
                }
            } else {
                NavigationView {
                    destinationView
                }
                .environmentObject(rootRouter)
            }
        }
        .sheet(isPresented: $isActiveSheet.willSet(execute: onChangeActiveState(_:)),
            content: {
            if #available(iOS 15, tvOS 15, *) {
                NavigationView {
                    destinationView
                }
            } else {
                NavigationView {
                    destinationView
                }
                .environmentObject(rootRouter)
            }
        })
        .alert(isPresented: $isActiveAlert.willSet(execute: onChangeActiveState(_:))) {
            guard let alert = alertView
            else { return Alert(title: Text("Something went wrong!")) }
            return alert
        }
        .actionSheet(isPresented: $isActiveActionSheet.willSet(execute: onChangeActiveState(_:)), content: {
            ActionSheet(title: Text(""))
        })
        .onChange(of: rootRouter.dismissAll, perform: { _ in
            resetActiveState()
        })
        .onChange(of: router.transition, perform: { (transition) in
            updateActiveState(from: transition)
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
    
    /// reset all active state to false
    private func resetActiveState() {
        guard scenePhase == .active || tests != nil else { return }
        isActivePush = false
        isActivePresent = false
        isActiveAlert = false
        isActiveSheet = false
        isActiveActionSheet = false
        router.resetTransition(scenePhase: scenePhase)
        // test - action
        tests?.resetActiveState?(self)
        //
    }
    
    /// Observe the active state change
    /// - Parameter isActive: active state of a navigation
    ///
    /// The transition should be reset to `.none` if the active state change to false
    private func onChangeActiveState(_ isActive: Bool) {
        if !isActive {
            router.resetTransition(scenePhase: scenePhase)
        }
    }
    
    /// Observe the transition change from router
    /// - Parameter transition: ``Transiton``
    private func updateActiveState(from transition: Transition<RouteType>) {
        switch transition.type {
        case .push:
            isActivePush = true
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
            rootRouter.tabbarSelection = transition.tabIndex ?? 0
            router.resetTransition(scenePhase: scenePhase)
        case .dismissAll:
            rootRouter.dismissToRoot()
        case .none: break
        }
        // test - action
        tests?.didChangeTransition?(self)
        //
    }
}
