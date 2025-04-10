//
//  SRNavigationPath.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation
import SwiftUI

/// NavigationStack's path
@MainActor
public final class SRNavigationPath: ObservableObject {
    
    @Published
    internal var stack: [String] = []
    
    public private(set) var navPath: Binding<NavigationPath>?
    
    private(set) weak var coordinator: SRRouteCoordinatorType?
    
    public init(coordinator: SRRouteCoordinatorType? = nil) {
        self.coordinator = coordinator
    }
    
    public func pop() {
        guard let navPath else { return }
        guard !navPath.wrappedValue.isEmpty else { return }
        navPath.wrappedValue.removeLast()
    }
    
    public func pop(to route: some SRRoute) {
        guard let navPath else { return }
        guard navPath.wrappedValue.count == stack.count, navPath.wrappedValue.count > 1 else { return }
        guard let index = stack.lastIndex(where: {$0.contains(route.fullPath)})
        else { return }
        let dropCount = (stack.count - 1) - index
        guard dropCount > 0 && navPath.wrappedValue.count >= dropCount else { return }
        navPath.wrappedValue.removeLast(dropCount)
    }
    
    public func popToRoot() {
        guard let navPath, !navPath.wrappedValue.isEmpty else { return }
        let count = navPath.wrappedValue.count
        navPath.wrappedValue.removeLast(count)
    }
    
    public func push(to route: some SRRoute) {
        navPath?.wrappedValue.append(route)
    }
}

//MARK: - Internal
extension SRNavigationPath {
    
    func matchingStack(from navCodable: NavigationPath.CodableRepresentation?) {
        
        guard let navCodable else { return }
        guard let data = try? JSONEncoder().encode(navCodable) else { return }
        guard let array = try? JSONDecoder().decode([String].self, from: data) else { return }
        
        let matchedArray = array.chunked(into: 2)
            .map( { $0.joined(separator: ".").replacingOccurrences(of: "\"", with: "") })
        if matchedArray.count < 2 {
            self.stack = matchedArray
        } else {
            self.stack = Array(matchedArray.reversed())
        }
    }
    
    func bindingPath(_ path: Binding<NavigationPath>) {
        navPath = path
    }
}
