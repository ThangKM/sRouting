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
                .aspectRatio(contentMode: .fill)
                .frame(width: 90, height: 120)
                .cornerRadius(6)
            
            VStack(alignment: .leading) {
                Text(book.name)
                Text(book.author)
                Spacer()
                RatingView(rating: .constant(book.rating), enableEditing: false)
            }
            .frame(height: 120)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
    }
}


#Preview {
    List {
        BookCell(book: .init(bookId: 1,
                             name: "Book Title",
                             imageName: "",
                             author: "Developer",
                             description: "testing",
                             rating: 3))
    }
}
