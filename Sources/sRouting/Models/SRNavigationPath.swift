//
//  SRNavigationPath.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation

/// NavigationStack's path
@Observable
public final class SRNavigationPath {
    
    @MainActor
    internal var stack: [AnyRoute] = []
    
    public private(set) var didAppear: Bool = false
    
    public init() { }
    
    @MainActor
    public func pop() {
        guard !stack.isEmpty else { return }
        stack.removeLast()
    }
    
    @MainActor
    public func pop(to route: some SRRoute) {
        let path = route.path
        guard let index = stack.lastIndex(where: {$0.path.contains(path)})
        else { return }
        let dropCount = (stack.count - 1) - index
        guard dropCount > 0 && stack.count >= dropCount else { return }
        stack.removeLast(dropCount)
    }
    
    @MainActor
    public func popToRoot() {
        guard !stack.isEmpty else { return }
        stack.removeAll()
    }
    
    @MainActor
    public func push(to route: some SRRoute) {
        stack.append(AnyRoute(route: route))
    }
    
    @MainActor
    internal func stackDidAppear() {
        guard !didAppear else { return }
        didAppear = true
    }
}
