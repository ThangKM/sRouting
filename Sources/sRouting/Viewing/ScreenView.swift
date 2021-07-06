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
    
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject
    var router: Router<RouteType>
    
    /// Content view builder
    private let content: () -> Content
    
    /// Initalizer of ``ScreenView``
    ///  - Parameters:
    ///   - rootRouter: Type of ``Router``
    ///   - content: Content view builder
    public init(router: Router<RouteType>,
                @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self.content = content
    }
    
    public var body: some View {
        return ZStack {
            NavigatorView(router: router) {
                presentationMode.wrappedValue.dismiss()
            }
            
            content()
        }
    }
}
