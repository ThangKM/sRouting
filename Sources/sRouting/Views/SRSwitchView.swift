//
//  SRSwitchView.swift
//  sRouting
//
//  Created by Thang Kieu on 26/4/25.
//

import SwiftUI


/// This view facilitates switching between root-level routes, such as transitioning between the main tab bar and the login view.
public struct SRSwitchView<R>: View where R: SRRoute {
    
    @Environment(SRContext.self) private var context: SRContext?
    @State private var switcher: SRSwitcher<R>
    @State private var route: R
    
    public init(inital route: R) {
        self._switcher = .init(initialValue: .init(route: route))
        self._route = .init(initialValue: route)
    }
    
    public var body: some View {
        route.screen
            .onChange(of: switcher.route, { _, newValue in
                Task {
                    context?.resetAll()
                    withAnimation {
                        route = newValue
                    }
                }
            })
            .environment(SwitcherBox(switcher: switcher))
    }
}


/// This view is similar to ``SRSwitchView``, but it provides the ability to modify the route.screen.
public struct SRSwitchRouteView<R, C>: View where R: SRRoute, C: View {
    
    @Environment(SRContext.self) private var context: SRContext?
    @State private var switcher: SRSwitcher<R>
    @State private var route: R
    let content: (R) -> C
    
    init(route: R, @ViewBuilder content: @escaping (R) -> C) {
        self._switcher = .init(initialValue: .init(route: route))
        self._route = .init(initialValue: route)
        self.content = content
    }
    
    public var body: some View {
        content(route)
            .onChange(of: switcher.route, { _, newValue in
                Task {
                    context?.resetAll()
                    withAnimation {
                        route = newValue
                    }
                }
            })
            .environment(SwitcherBox(switcher: switcher))
    }
}


