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
    @State private var isActivePush: Bool = false
    /// Active state of a full screen presentation
    @State private var isActivePresent: Bool = false
    /// Active state of a sheet presentation
    @State private var isActiveSheet: Bool = false
    /// Active state of a alert
    @State private var isActiveAlert: Bool = false

    /// Dismiss action of presentationMode from @Enviroment
    private let dismissAction: VoidAction
    /// The destination screen from transition
    private let destinationView: RouteType.ViewType?
    /// The alert from transition
    private let alertView: Alert?
    
    init(router: Router<RouteType>,
         onDismiss: @escaping VoidAction) {
        self.router = router
        self.dismissAction = onDismiss
        self.destinationView = router.transition.screenView
        self.alertView = router.transition.alert
    }
    
    var body: some View {
        Group {
            NavigationLink(
                destination: destinationView,
                isActive: $isActivePush.willSet(execute: onChangeActiveState(_:)),
                label: {
                    EmptyView()
                })
        }
//        #if os(iOS)
//        .fullScreenCover(isPresented: $isActivePresent.willSet(execute: onChangeActiveState(_:))) {
//            NavigationView {
//                destinationView
//            }
//        }
//        #endif
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
}

extension NavigatorView {
    
    /// reset all active state to false
    private func resetActiveState() {
        guard scenePhase == .active else { return }
        isActivePush = false
        isActivePresent = false
        isActiveAlert = false
        isActiveSheet = false
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
        switch transition.type {
        case .push:
            isActivePush = true
        case .present:
            isActivePresent = true
        case .sheet:
            isActiveSheet = true
        case .alert:
            isActiveAlert = true
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
