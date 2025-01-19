//
//  RootPreview.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import sRouting
import SwiftUI

@sRouteCoordinator(stacks: "rootPreviewStack")
final class PreviewCoordinator { }

struct RootPreview<Content>: View where Content: View {
    
    @State private var coordinator = PreviewCoordinator()
    let content: () -> Content
    
    var body: some View {
        SRRootView(coordinator: coordinator) {
            NavigationStack(path: coordinator.rootPreviewStackPath) {
                content()
                    .routeObserver(RouteObserver.self)
            }
        }
    }
}
