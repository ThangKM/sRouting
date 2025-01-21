//
//  FontModifier.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI

struct FontModifier: ViewModifier {
    
    enum Style {
        case regular
        case italic
    }
    
    let size: CGFloat
    let style: Style
    
    func body(content: Content) -> some View {
        content.font(.custom(_abbeezeeName(ofStyle: style), size: size))
    }
    
    private func _abbeezeeName(ofStyle style: Style) -> String {
        switch style {
        case .regular:
            "ABeeZee-Regular"
        case .italic:
            "ABeeZee-italic"
        }
    }
}

extension View {
    
    nonisolated func abeeFont(size: CGFloat, style: FontModifier.Style) -> some View {
        self.modifier(FontModifier(size: size, style: style))
    }
}
