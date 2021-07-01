//
//  RootView.swift
//  sRouting
//
//  Created by ThangKieu on 6/28/21.
//

import SwiftUI

/// The root view of the application
public struct RootView<Content, RootRouterType>: View
where Content: View, RootRouterType: RootRouter {
    
    ///Using to inject the rootRouter into environment as ``RootRouter`` Type
    @ObservedObject
    private var baseRootRouter: RootRouter
    
    ///Using to inject the rootRouter into environment as RootRouterType Type
    @ObservedObject
    private var rootRouter: RootRouterType
    
    private let content: () -> Content

    
    init(rootRouter: RootRouterType,
         @ViewBuilder content: @escaping () -> Content) {
        self.rootRouter = rootRouter
        self.baseRootRouter = rootRouter
        self.content = content
    }
    
    public var body: some View {
        Group {
            content()
        }
        .environmentObject(baseRootRouter)
        .environmentObject(rootRouter)
    }
}
