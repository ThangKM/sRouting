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
    
    public let router: Router<RouteType>
    
    /// Content View
    @ViewBuilder
    public let content: Content
    
    public var body: some View {
        return ZStack {
            NavigatorView(router: router) {
                presentationMode.wrappedValue.dismiss()
            }
            
            content
        }
    }
}
