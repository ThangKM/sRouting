//
//  RatingView.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import SwiftUI

struct RatingView: View {
    
    @Binding var rating: Int
    let enableEditing: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<5) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .onTapGesture {
                        withAnimation {
                            rating = index + 1
                        }
                    }
            }
        }
        .foregroundColor(Color.yellow)
        .disabled(!enableEditing)
    }
}

#Preview {
    RatingView(rating: .constant(6), enableEditing: false)
}
