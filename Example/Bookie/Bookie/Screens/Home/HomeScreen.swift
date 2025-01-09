//
//  HomeScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

struct HomeScreen: View {
    
    @State
    private var viewModel: HomeViewModel = .init()
    
    @State
    private var router = SRRouter(HomeRoute.self)
    
    @Environment(MockBookData.self)  private var mockData
    
    var body: some View {
        BookieNavigationView(title: "My Book List",
                             router: router,
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
                
                List(viewModel.books) { book in
                    BookCell(book: book)
                        .onTapGesture {
                            router.trigger(to: .bookDetailScreen(book: book), with: .allCases.randomElement() ?? .push)
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

#Preview {
    Group {
        HomeScreen()
    }.environment(MockBookData())
}