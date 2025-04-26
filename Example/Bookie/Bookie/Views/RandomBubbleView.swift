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
    
    @State var position: CGPoint = .zero
    @State var scale: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ForEach(0..<bubbles.count,id: \.self) { index in
                    let size = CGFloat.random(in: minWidth...maxWidth)
                    LinearGradient(colors: bubbles[index], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(width: size, height: size)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .opacity(position == .zero ? 0.1 : 1)
                        .scaleEffect(scale)
                        .position(scale == 1 ? position : randomPosition(in: geometry.size))
                }
            }
            .animation(.easeInOut(duration: 0.5), value: scale)
            .onAppear() {
                position = randomPosition(in: geometry.size)
                Task {
                    try await Task.sleep(for: .milliseconds(.random(in: 300...500)))
                    withAnimation {
                       scale = 1.0
                    }
                }
            }
        }
        .transition(.opacity)
    }
    
    private func randomPosition(in size: CGSize) -> CGPoint {
        let x = CGFloat.random(in: -5...size.width)
        let y = CGFloat.random(in: -5...size.height)
        return CGPoint(x: x, y: y)
    }
        
}
