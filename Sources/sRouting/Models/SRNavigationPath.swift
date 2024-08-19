//
//  SRNavigationPath.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation
import SwiftUI

/// NavigationStack's path
@Observable
public final class SRNavigationPath {
    
    @MainActor
    internal var stack: [AnyRoute] = []
    
    @MainActor
    internal var navPath: NavigationPath = .init()
    
    public private(set) var didAppear: Bool = false
    
    public init() { }
    
    @MainActor
    public func pop() {
        guard !navPath.isEmpty else { return }
        navPath.removeLast()
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
        guard !navPath.isEmpty else { return }
        let count = navPath.count
        navPath.removeLast(count)
    }
    
    @MainActor
    public func push(to route: some SRRoute) {
        navPath.append(route)
    }
    
    @MainActor
    internal func stackDidAppear() {
        guard !didAppear else { return }
        didAppear = true
    }
}
