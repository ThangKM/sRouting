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
        switch style {
        case .regular:
            content.font(.custom("ABeeZee-Regular", size: size))
        case .italic:
            content.font(.custom("ABeeZee-italic", size: size))
        }
    }
}

extension View {
    func abeeFont(size: CGFloat, style: FontModifier.Style) -> some View {
        self.modifier(FontModifier(size: size, style: style))
    }
}
