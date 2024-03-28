//
//  ScreenView.swift
//  sRouting
//
//  Created by ThangKieu on 08/02/2021.
//

import SwiftUI

/// The View that is a screen.
@MainActor
public struct ScreenView<Content, RouterType>: View
where Content: View, RouterType: SRRouterType {
    
    private let dismissAction: DismissAction?
    private var router: RouterType
    
    /// Content view builder
    private let content: () -> Content
    private let tests: UnitTestActions<Self>?
    
    /// Initalizer of ``ScreenView``
    ///  - Parameters:
    ///   - router: Type of ``Router``
    ///   - dismissAction: `DismissAction`
    ///   - content: Content view builder
    public init(router: RouterType,
                dismissAction:DismissAction,
                @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self.dismissAction = dismissAction
        self.content = content
        self.tests = nil
    }
    
    internal init(router: RouterType,
                  dismissAction: DismissAction?,
                  tests: UnitTestActions<Self>?,
                @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self.dismissAction = dismissAction
        self.content = content
        self.tests = tests
    }
    
    public var body: some View {
        ZStack {
            NavigatorView(router: router) {
                dismissAction?()
                tests?.dismissAction?()
            }
            content()
        }
        .onAppear {
            tests?.didAppear?(self)
        }
    }
}
