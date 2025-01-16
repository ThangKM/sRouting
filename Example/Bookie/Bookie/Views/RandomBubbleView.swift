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
    
    @State var hidden: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<bubbles.count,id: \.self) { index in
                let size = CGFloat.random(in: minWidth...maxWidth)
                LinearGradient(colors: bubbles[index], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: size, height: size)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .position(x: CGFloat.random(in: -5...geometry.size.width),
                              y: CGFloat.random(in: -5...geometry.size.height))
                    .transition(.asymmetric(insertion: .scale(scale: 3).combined(with: .opacity),
                                            removal: .scale(scale: 0.2).combined(with: .opacity)))
                    .animation(.easeInOut(duration: 1), value: 1)
            }
        }
        .opacity(hidden ? 0 : 1)
        .onAppear {
            Task {
                try await Task.sleep(for: .milliseconds(400))
                withAnimation {
                    hidden.toggle()
                }
            }
        }
    }
}
