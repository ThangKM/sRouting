//
//  RootView.swift
//  sRouting
//
//  Created by ThangKieu on 6/28/21.
//

import SwiftUI

/// The root view of the application
public struct RootView<Content>: View
where Content: View {
    
    @StateObject
    private var rootRouter: RootRouter = .init()
    
    /// Content View
    @ViewBuilder
    public let content: Content
    
    public var body: some View {
        Group {
            content
        }
        .environmentObject(rootRouter)
    }
}
