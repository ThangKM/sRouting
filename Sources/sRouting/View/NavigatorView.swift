//
//  NavigatorView.swift
//  Sequence
//
//  Created by ThangKieu on 2/19/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct NavigatorView<RouteType>: View
where RouteType: Route {
    
    typealias VoidAction = () -> Void
    
    @ObservedObject
    private var router: Router<RouteType>

    @EnvironmentObject
    private var rootRouter: RootRouter
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isActivePush: Bool = false
    @State private var isActivePresent: Bool = false
    @State private var isActiveSheet: Bool = false
    @State private var isActiveAlert: Bool = false

    private let dismissAction: VoidAction
    private let destinationView: RouteType.ViewType?
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
        .onChange(of: rootRouter.dismissAll, perform: { _ in
            resetActiveState()
        })
        .onChange(of: router.transition, perform: { (transition) in
            updateActiveState(from: transition)
        })
        .hidden()
    }
}

@available(iOS 15.0, *)
extension NavigatorView {
    
    private func resetActiveState() {
        guard scenePhase == .active else { return }
        isActivePush = false
        isActivePresent = false
        isActiveAlert = false
        isActiveSheet = false
        router.resetTransition(scenePhase: scenePhase)
    }
    
    private func onChangeActiveState(_ isActive: Bool) {
        if !isActive {
            router.resetTransition(scenePhase: scenePhase)
        }
    }
    
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
