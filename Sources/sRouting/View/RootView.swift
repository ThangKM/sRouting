//
//  RootView.swift
//  sequence
//
//  Created by ThangKieu on 6/28/21.
//

import SwiftUI

@available(iOS 15.0, *)
public struct RootView<Content>: View
where Content: View {
    
    @StateObject
    private var rootRouter: RootRouter = .init()
    
    @ViewBuilder
    public let content: Content
    
    public var body: some View {
        Group {
            content
        }
        .environmentObject(rootRouter)
    }
}
