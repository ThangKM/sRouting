//
//  AnyRoute.swift
//
//
//  Created by Thang Kieu on 20/03/2024.
//

import SwiftUI

/// A type-erased SRRoute.
public struct AnyRoute: SRRoute {
    
    public let path: String
    private let viewBuilder:  @MainActor @Sendable () -> AnyView
    
    public var screen: some View {
        viewBuilder().id(path)
    }
    
    public init(route: some SRRoute) {
        self.path = route.path + "_" + TimeIdentifier().id
        self.viewBuilder = {
            AnyView(route.screen)
        }
    }
}
