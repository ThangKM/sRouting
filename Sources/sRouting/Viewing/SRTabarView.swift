//
//  SRTabarView.swift
//  sRouting
//
//  Created by ThangKieu on 6/28/21.
//

import SwiftUI

/// Tabar's selection Observation
@Observable @MainActor
internal final class SRTabarSelection {
    var tabSelection: Int = 0
}

/// The root view of the application
@MainActor
public struct SRTabarView<Content>: View where Content: View {
    
    @State private var selection: SRTabarSelection = .init()
    private let content: () -> Content

    /// Creates an instance of `TabView` that selects from content associated with
    /// `Selection` values.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        TabView(selection: $selection.tabSelection) {
            content()
        }.environment(selection)
    }
}
