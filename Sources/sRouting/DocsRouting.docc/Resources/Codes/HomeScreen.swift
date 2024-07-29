//
//  HomeScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI

struct HomeScreen: View {
    
    @State
    private var viewModel: HomeViewModel = .init()
    
    @Environment(MockBookData.self)  private var mockData
    
    var body: some View {
        BookieNavigationView(title: "My Book List",
                             router: viewModel,
                             isBackType: false) {
            VStack {
                Group {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .opacity(0.4)
                        TextField("Search books", text: $viewModel.textInSearch)
                            .keyboardType(.webSearch)
                            .abeeFont(size: 14, style: .italic)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                
                Text("BOOKS REVIEWED BY YOU")
                    .abeeFont(size: 12, style: .italic)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                List(viewModel.books, id: \.id) { book in
                    BookCell(book: book)
                        .overlay {
                            NavigationLink(route: HomeRoute.bookDetailScreen(book: book)) {
                               EmptyView()
                            }.opacity(0)
                        }
                        
                }
                .listRowSpacing(15)
                .scrollContentBackground(.hidden)
                .contentMargins(.all,
                                EdgeInsets(top: .zero, leading: 10, bottom: 20, trailing: 15),
                                for: .scrollContent)
            }
        }
         .refreshable {
             viewModel.updateAllBooks(books: mockData.books)
         }
        .onAppear {
            viewModel.updateAllBooks(books: mockData.books)
        }
        .onChange(of: mockData.books) { _, newValue in
            viewModel.updateAllBooks(books: newValue, isForceUpdate: true)
        }
    }
}
