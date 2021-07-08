//
//  RandomBubbleView.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI

struct RandomBubbleView: View {
    
    let bubbles: [[Color]]
    let minWidth: CGFloat
    let maxWidth: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<bubbles.count) { index in
                let size = CGFloat.random(in: minWidth...maxWidth)
                LinearGradient(colors: bubbles[index], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: size, height: size)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .position(x: CGFloat.random(in: -5...geometry.size.width), y: CGFloat.random(in: -5...geometry.size.height))
            }
        }
    }
}
