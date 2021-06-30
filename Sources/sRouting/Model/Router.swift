//
//  ScreenObservable.swift
//  Sequence
//
//  Created by ThangKieu on 2/19/21.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
open class Router<RouteType>: ObservableObject
where RouteType: Route {
    
    private(set) var transition: Transition<RouteType> = .none
    
    internal func resetTransition(scenePhase: ScenePhase) {
        guard scenePhase == .active else { return }
        transition = .none
    }
    
    open func selectTabbar(at index: Int) {
        transition = .init(selectTab: index)
        objectWillChange.send()
    }
    
    open func trigger(to route: RouteType, with action: TransitionType) {
        transition = .init(with: route, and: action)
        objectWillChange.send()
    }
    
    open func show(error: Error, and title: String? = nil) {
        transition = .init(with: error, and: title)
        objectWillChange.send()
    }
    
    open func dismiss() {
        transition = .init(with: .dismiss)
        objectWillChange.send()
    }
    
    open func dismissAll() {
        transition = .init(with: .dismissAll)
        objectWillChange.send()
    }
}
