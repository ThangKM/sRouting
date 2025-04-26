//
//  SRNavigationPath.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation
import SwiftUI

/// NavigationStack's path
@Observable @MainActor
public final class SRNavigationPath {
    
    internal var stack: [String] = []
    
    internal var navPath: NavigationPath = .init() {
        willSet {
            _matchingStack(from: newValue.codable)
        }
    }
    
    @ObservationIgnored
    private(set) weak var coordinator: SRRouteCoordinatorType?
    
    public var pathsCount: Int {
        navPath.count
    }
    
    public init(coordinator: SRRouteCoordinatorType? = nil) {
        self.coordinator = coordinator
    }
    
    public func pop() {
        guard !navPath.isEmpty else { return }
        navPath.removeLast()
    }
    
    public func pop(to path: some StringRawRepresentable) {
        guard navPath.count == stack.count, navPath.count > 1 else { return }
        guard let index = stack.lastIndex(where: {$0.contains(path.stringValue)})
        else { return }
        let dropCount = (stack.count - 1) - index
        guard dropCount > 0 && navPath.count >= dropCount else { return }
        navPath.removeLast(dropCount)
    }
    
    public func popToRoot() {
        guard !navPath.isEmpty else { return }
        let count = navPath.count
        navPath.removeLast(count)
    }
    
    public func push(to route: some SRRoute) {
        navPath.append(route)
    }
    
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
