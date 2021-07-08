//
//  HomeScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI

struct HomeScreen: View {
    
    @StateObject
    private var viewModel: HomeViewModel = .init()
    
    @EnvironmentObject
    private var mockData: MockBookData
    
    var body: some View {
        BookieNavigationView(title: "My Book List",
                             router: viewModel,
                             isBackType: false) {
            GeometryReader { geo in
                ScrollView {
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
                    
                    
                    LazyVStack {
                        ForEach(viewModel.books) { book in
                            BookCell(book: book)
                                .onTapGesture {
                                    viewModel.pushDetail(of: book)
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 20)
                }
                .foregroundColor(.accentColor)
            }
        }
        .onAppear {
            viewModel.updateAllBooks(books: mockData.books)
        }
        .onChange(of: mockData.books) {
            viewModel.updateAllBooks(books: $0, isForceUpdate: true)
        }
    }
}
