//
//  AnyRoute.swift
//
//
//  Created by Thang Kieu on 20/03/2024.
//

import SwiftUI
import Foundation

/// A type-erased SRRoute.
public struct AnyRoute: SRRoute {
    
    public let path: String
    private let viewBuilder:  @MainActor () -> AnyView
    
    public var screen: some View {
        viewBuilder().id(path)
    }
    
    public init(route: some SRRoute) {
        self.path = route.path + "_" + TimeIdentifier.newId()
        self.viewBuilder = {
            AnyView(route.screen)
        }
    }
}
