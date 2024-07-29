//
//  BookCell.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI

struct BookCell: View {
    
    let book: BookModel
    
    var body: some View {
        HStack {
            Image(book.imageName.isEmpty ? "image.default" : book.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 109, alignment: .leading)
                .clipped()
                .onTapGesture {
                    print("abc")
                }
            
            VStack(alignment: .leading) {
                Text(book.name)
                Text(book.author)
                Spacer()
                RatingView(rating: .constant(book.rating))
            }
            Spacer()
        }
        .padding()
        .frame(height: 147)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


#Preview {
    List {
        BookCell(book: .init(id: 1,
                             name: "Book Title",
                             imageName: "",
                             author: "Developer",
                             description: "testing",
                             rating: 3))
    }
}
