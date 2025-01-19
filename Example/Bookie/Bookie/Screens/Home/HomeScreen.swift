//
//  HomeScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

struct HomeScreen: View {
    
    @State private var router = SRRouter(HomeRoute.self)
    @State private var state = HomeState()
    @State private var store = HomeStore()
    @Environment(MockBookService.self) private var bookService
    
    var body: some View {
        BookieNavigationView(title: "My Book List",
                             router: router,
                             isBackType: false)
        {
            VStack {
                
                SearchBody(state: state)

                Text("BOOKS REVIEWED BY YOU")
                    .abeeFont(size: 12, style: .italic)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ListBookBody(state: state, store: store)
            }
            .refreshable {
                store.receive(action: .fetchAllBooks)
            }
            
        }
        .onRouting(of: router)
        .onChange(of: state.seachText, { oldValue, newValue in
             store.receive(action: .findBooks(text: newValue))
         })
        .onChange(of: bookService.books) { _, _ in
             store.receive(action: .fetchAllBooks)
             store.receive(action: .findBooks(text: state.seachText))
         }
        .task {
            store.binding(state: state)
            store.binding(bookService: bookService, router: router)
            store.receive(action: .fetchAllBooks)
         }
    }
}

//MARK: - SearchBody
extension HomeScreen {
    
    enum FocusField: String {
        case searchText
    }
    
    fileprivate struct SearchBody: View {
        
        @Bindable var state: HomeState
        @FocusState private var focus: FocusField?
        
        var body: some View {
            HStack {
                
                Image(systemName: "magnifyingglass")
                    .opacity(0.4)
                
                TextField("Search books", text: $state.seachText)
                    .focused($focus, equals: .searchText)
                    .keyboardType(.webSearch)
                    .abeeFont(size: 14, style: .italic)
                    
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .onTapGesture {
                focus = .searchText
            }
        }
    }
}

//MARK: - ListBookBody
extension HomeScreen {
    
    fileprivate struct ListBookBody: View {
        
        let state: HomeState
        let store: HomeStore
        
        var body: some View {
            List(state.books) { book in
                BookCell(book: book)
                    .onTapGesture {
                        store.receive(action: .gotoDetail(book: book))
                    }
                
            }
            .listRowSpacing(15)
            .scrollContentBackground(.hidden)
            .contentMargins(.all,
                            EdgeInsets(top: .zero, leading: 10, bottom: 20, trailing: 15),
                            for: .scrollContent)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(MockBookPreviewModifier())) {
    RootPreview {
        HomeScreen()
    }
}

//MARK: - Preview
@available(iOS 18.0, *)
#Preview(traits: .modifier(HomeStatePreviewModifier())) {
    
    @Previewable @Environment(HomeScreen.HomeState.self) var state
    @Previewable @State var store = HomeScreen.HomeStore()
    
    HomeScreen.ListBookBody(state: state, store: store)
        .background(Color.gray)
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(HomeStatePreviewModifier())) {
    
    @Previewable @Environment(HomeScreen.HomeState.self) var state
    VStack {
        HomeScreen.SearchBody(state: state)
            
    }
    .frame(maxHeight: .infinity)
    .background(Color.gray)
}
