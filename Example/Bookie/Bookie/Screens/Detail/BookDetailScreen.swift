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

    init(state: DetailState) {
        _state = .init(initialValue: state)
    }
    
    var body: some View {
        BookieNavigationView(title: state.book.name,
                             router: router,
                             isBackType: true) {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    
                    BookHeaderBody(state: state)
                    
                    Text(state.book.description)
                        .abeeFont(size: 14, style: .italic)
                        .padding()
                    
                    Divider()
                    
                    VStack(spacing: 8) {
                        
                        Text("TAP TO ADD RATING")
                            .abeeFont(size: 20, style: .italic)
                        
                        RatingView(rating: $state.rating, enableEditing: true)
                        
                        Spacer(minLength: 40)
                        
                        Button("Delete") {
                            store.receive(action: .deleteBook)
                        }
                        .abeeFont(size: 15, style: .regular)
                        .tint(Color.pink)
                        .foregroundStyle(.white)
                        .buttonStyle(.borderedProminent)
                        .disabled(state.isLoading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .onRouting(of: router)
        .onChange(of: state.rating, { oldValue, newValue in
            store.receive(action: .saveBook)
        })
        .foregroundColor(.accentColor)
        .task {
            store.binding(state: state, router: router)
        }
    }
}

//MARK: - BookHeaderBody
extension BookDetailScreen {
    
    fileprivate struct BookHeaderBody: View {
        
        let state: DetailState
        
        var body: some View {
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
        }  
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(DetailStatePreviewModifier())) {
    
    @Previewable @Environment(BookDetailScreen.DetailState.self) var state
    BookDetailScreen(state: state)
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(DetailStatePreviewModifier())) {
    
    @Previewable @Environment(BookDetailScreen.DetailState.self) var state
    
    BookDetailScreen.BookHeaderBody(state: state)
        .background(Color.gray)
}
