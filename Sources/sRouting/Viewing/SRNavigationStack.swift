//
//  SRNavigationStack.swift
//
//
//  Created by Thang Kieu on 20/03/2024.
//

import SwiftUI
import Observation

@Observable @MainActor
internal final class SRNavigationPath {
    
    var stack: [AnyRoute]
    
    init() {
        stack = []
    }
    
    func pop() {
        guard !stack.isEmpty else { return }
        stack.removeLast()
    }
    
    func pop(to route: some SRRoute) {
        let path = route.path
        guard let index = stack.lastIndex(where: {$0.path.contains(path)})
        else { return }
        let dropCount = (stack.count - 1) - index
        guard dropCount > 0 && stack.count >= dropCount else { return }
        stack.removeLast(dropCount)
    }
    
    func popToRoot() {
        guard !stack.isEmpty else { return }
        stack.removeAll()
    }
    
    func push(to route: some SRRoute) {
        let index = stack.count
        let path = Self._anyPath(index: index, path: route.path)
        let anyRoute = AnyRoute(route: route, path: path)
        stack.append(anyRoute)
    }
    
    private static func _anyPath(index: Int, path: String) -> String {
        "\(index):\(path)"
    }
}

@MainActor
public struct SRNavigationStack<Content>: View where Content: View {
    
    @State private var path: SRNavigationPath = .init()
    
    private let content: () -> Content

    /// Initalizer of ``SRNavigationStack``
    ///  - Parameters:
    ///   - content: Content view builder
    public init( @ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        NavigationStack(path: $path.stack) {
            content()
            .navigationDestination(for: AnyRoute.self) { route in
                #if os(iOS)
                route.screen
                #else
                route.screen.environment(path)
                #endif
            }
        }.environment(path)
    }
}

