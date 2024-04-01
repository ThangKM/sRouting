//
//  SRTabarView.swift
//  sRouting
//
//  Created by ThangKieu on 6/28/21.
//

import SwiftUI

/// The root view of the application
public struct SRTabarView<Content>: View where Content: View {
    
    @Bindable private var selection: SRTabarSelection
    private let content: () -> Content

    /// Creates an instance of `TabView` that selects from content associated with
    /// `Selection` values.
    public init(selection: SRTabarSelection, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.selection = selection
    }
    
    public var body: some View {
        TabView(selection: $selection.selection) {
            content()
        }.environment(selection)
    }
}
