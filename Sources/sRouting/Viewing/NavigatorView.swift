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
    @State private var isActivePresent: Bool = false
    /// Active state of a sheet presentation
    @State private var isActiveSheet: Bool = false
    /// Active state of a alert
    @State private var isActiveAlert: Bool = false
    /// Active state of action sheet
    @State private var isActiveActionSheet: Bool = false

    /// Dismiss action of presentationMode from @Enviroment
    private let dismissAction: VoidAction
    /// The destination screen from transition
    @ViewBuilder
    private var destinationView: some View {
        router.transition.screenView
    }
    /// The alert from transition
    private let alertView: Alert?
    
    #if os(iOS) && os(tvOS)
    /// The ActionSheet from transaction
    private var actionSheet: ActionSheet?
    
    init(router: Router<RouteType>,
         onDismiss: @escaping VoidAction) {
        self.router = router
        self.dismissAction = onDismiss
        self.alertView = router.transition.alert
        self.actionSheet = router.transition.actionSheet
    }
    
    #else
    init(router: Router<RouteType>,
         onDismiss: @escaping VoidAction) {
        self.router = router
        self.dismissAction = onDismiss
        self.alertView = router.transition.alert
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
            NavigationView {
                destinationView
            }
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
            NavigationView {
                destinationView
            }
        }
        .sheet(isPresented: $isActiveSheet.willSet(execute: onChangeActiveState(_:)),
            content: {
            NavigationView {
                destinationView
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
        .hidden()
    }
    #endif
}

extension NavigatorView {
    
    /// reset all active state to false
    private func resetActiveState() {
        guard scenePhase == .active else { return }
        isActivePush = false
        isActivePresent = false
        isActiveAlert = false
        isActiveSheet = false
        isActiveActionSheet = false
        router.resetTransition(scenePhase: scenePhase)
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
        print("onChangeState")
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
    }
}
