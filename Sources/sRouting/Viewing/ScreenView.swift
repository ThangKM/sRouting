//
//  ScreenView.swift
//  sRouting
//
//  Created by ThangKieu on 08/02/2021.
//

import SwiftUI

/// The View that is a screen.
public struct ScreenView<Content, RouteType>: View
where Content: View, RouteType: Route {
    
    @Binding
    private var presentationMode: PresentationMode
    
    @ObservedObject
    private var router: Router<RouteType>
    
    /// Content view builder
    private let content: () -> Content
    
    private let tests: UnitTestActions<Self,RouteType>?
    
    /// Initalizer of ``ScreenView``
    ///  - Parameters:
    ///   - rootRouter: Type of ``Router``
    ///   - content: Content view builder
    public init(router: Router<RouteType>,
                presentationMode: Binding<PresentationMode>,
                @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self._presentationMode = presentationMode
        self.content = content
        self.tests = nil
    }
    
    internal init(router: Router<RouteType>,
                presentationMode: Binding<PresentationMode>,
                  tests: UnitTestActions<Self,RouteType>,
                @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self._presentationMode = presentationMode
        self.content = content
        self.tests = tests
    }
    
    public var body: some View {
        ZStack {
            NavigatorView(router: router) {
                presentationMode.dismiss()
                tests?.dismissAction?()
            }
            
            content()
        }
        .onAppear {
            tests?.didAppear?(self)
        }
    }
}
