//
//  SRTabbarView.swift
//  sRouting
//
//  Created by ThangKieu on 6/28/21.
//

import SwiftUI

/// The root view of the application
public struct SRTabbarView<Content>: View where Content: View {
    
    @Environment(SRTabbarSelection.self) private var selection
    
    private let content: () -> Content

    /// Creates an instance of `TabView` that selects from content associated with
    /// `Selection` values.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        TabView(selection: .init(get: {
            selection.selection
        }, set: { value in
            selection.select(tag: value)
        })) {
            content()
        }
    }
}
 
