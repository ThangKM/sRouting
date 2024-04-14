//
//  RatingView.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import SwiftUI

struct RatingView: View {
    
    @Binding var rating: Int
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<5) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .onTapGesture {
                        rating = index + 1
                    }
            }
        }
        .foregroundColor(Color.yellow)
    }
}
