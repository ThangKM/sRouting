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
    internal var stack: [String] = []
    
    @MainActor @ObservationIgnored
    internal var navPath: NavigationPath {
        get {
            access(keyPath: \.navPath)
            return _navPath
        }
        set {
            _matchingStack(from: newValue.codable)
            withMutation(keyPath: \.navPath) {
                _navPath = newValue
            }
        }
    }
    
    @ObservationIgnored
    private var _navPath: NavigationPath = .init()
    
    public private(set) var didAppear: Bool = false
    
    public init() { }
    
    @MainActor
    public func pop() {
        guard !navPath.isEmpty else { return }
        navPath.removeLast()
    }
    
    @MainActor
    public func pop(to route: some SRRoute) {
        guard navPath.count == stack.count else { return }
        let path = Helpers.navigationStoredPath(for: route)
        guard let index = stack.lastIndex(where: {$0.contains(path)})
        else { return }
        let dropCount = (stack.count - 1) - index
        guard dropCount > 0 && stack.count >= dropCount && navPath.count >= dropCount else { return }
        navPath.removeLast(dropCount)
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
    
    @MainActor
    private func _matchingStack(from navCodable: NavigationPath.CodableRepresentation?) {
        
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
}

extension Array {
    fileprivate func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
