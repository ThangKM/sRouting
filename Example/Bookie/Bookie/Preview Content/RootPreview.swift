//
//  RootPreview.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import sRouting
import SwiftUI

@sRouteCoordinator(stacks: "rootPreviewStack")
@Observable
final class PreviewCoordinator { }

struct RootPreview<Content>: View where Content: View {
    
    @State private var coordinator = PreviewCoordinator()
    @State private var context = SRContext()
    
    let content: () -> Content
    
    var body: some View {
        SRRootView(context: context, coordinator: coordinator) {
            NavigationStack(path: coordinator.rootPreviewStackPath) {
                content()
                    .routeObserver(RouteObserver.self)
            }
        }
    }
}
