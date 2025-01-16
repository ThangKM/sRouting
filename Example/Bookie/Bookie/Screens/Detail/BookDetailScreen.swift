//
//  BookDetailScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

struct BookDetailScreen: View {
    
    @State private var router = SRRouter(HomeRoute.self)
    @State private var state: DetailState
    @State private var store = DetailStore()
    
    @Environment(MockBookService.self) private var bookService
    
    init(state: DetailState) {
        _state = .init(initialValue: state)
    }
    
    var body: some View {
        BookieNavigationView(title: state.book.name,
                             router: router,
                             isBackType: true) {
            GeometryReader { geo in
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        HStack(spacing: 10) {
                            Image(state.book.imageName.isEmpty
                                  ? "image.default"
                                  : state.book.imageName)
                                .resizable()
                                .frame(width: 130, height: 203)
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text(state.book.name)
                                    .abeeFont(size: 20, style: .italic)
                                Text(state.book.author)
                                    .abeeFont(size: 16, style: .italic)
                                HStack(alignment:.center ,spacing: 3) {
                                    Text("Rating:")
                                    Text("\(state.book.rating)")
                                    Image(systemName:"star.fill")
                                }
                                .abeeFont(size: 12, style: .italic)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text(state.book.description)
                            .abeeFont(size: 14, style: .italic)
                            .padding()
                        
                        Divider()
                        
                        VStack(spacing: 8) {
                            Text("TAP TO ADD RATING")
                            RatingView(rating: $state.rating, enableEditing: true)
                            
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
        .task {
            store.binding(state: state)
            store.binding(bookService: bookService)
        }
        .onDisappear {
            store.receive(action: .saveBook)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(MockBookPreviewModifier())) {
    
    @Previewable @Environment(MockBookService.self) var mockData
    
    BookDetailScreen(state: .init(book: mockData.books.first!))
}
