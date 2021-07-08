//
//  BookDetailScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI

struct BookDetailScreen: View {
    
    @StateObject
    private var viewModel: BookDetailViewModel = .init()
    
    @EnvironmentObject
    private var mockData: MockBookData
    
    let book: BookModel
    
    var body: some View {
        BookieNavigationView(title: viewModel.book.name,
                             router: viewModel,
                             isBackType: true) {
            GeometryReader { geo in
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        HStack(spacing: 10) {
                            Image(viewModel.book.imageName.isEmpty
                                  ? "image.default"
                                  : viewModel.book.imageName)
                                .resizable()
                                .frame(width: 130, height: 203)
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text(viewModel.book.name)
                                    .abeeFont(size: 20, style: .italic)
                                Text(viewModel.book.author)
                                    .abeeFont(size: 16, style: .italic)
                                HStack(alignment:.center ,spacing: 3) {
                                    Text("Rating:")
                                    Text("\(viewModel.book.rating)")
                                    Image(systemName:"star.fill")
                                }
                                .abeeFont(size: 12, style: .italic)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text(viewModel.book.description)
                            .abeeFont(size: 14, style: .italic)
                            .padding()
                        
                        Divider()
                        
                        VStack(spacing: 8) {
                            Text("TAP TO ADD RATING")
                            RatingView(rating: $viewModel.book.rating)
                        }
                        .frame(maxWidth: .infinity)
                        .abeeFont(size: 20, style: .italic)
                        .padding()
                    }
                }
                .padding(.bottom, geo.safeAreaInsets.bottom + 20)
            }
        }
        .foregroundColor(.accentColor)
        .onAppear {
            viewModel.updateBook(book)
        }
        .onDisappear {
            mockData.updateBook(book: viewModel.book)
        }
    }
}
