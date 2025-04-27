//
//  HomeScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting
import SwiftData

struct HomeScreen: View {
    
    @State private var router = SRRouter(HomeRoute.self)
    @State private var state = HomeState()
    @State private var store = HomeStore()

    var body: some View {
        VStack {
            
            SearchBody(state: state)

            Text("BOOKS REVIEWED BY YOU")
                .abeeFont(size: 12, style: .italic)
                .padding(.all, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ListBookBody(state: state, store: store)
        }
        .refreshable {
            store.receive(action: .refreshBooks)
        }
        .onRouting(of: router)
        .bookieNavigation(title: "My Book List")
        .onChange(of: state.seachText, { oldValue, newValue in
             store.receive(action: .searchBookBy(text: newValue))
         })
        .task {
            await store.binding(state: state)
            await store.binding(router: router)
            store.receive(action: .firstFetchBooks)
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
        @State private var isShowSearchIcon = true
        
        var body: some View {
            HStack {
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("purple.F66EB4"))
                    .opacity(isShowSearchIcon ? 0.4 : 0)
                    .frame(width: isShowSearchIcon ? 24 : 0)
                    .animation(.easeInOut, value: isShowSearchIcon)
                    .clipped()
                
                TextField("Search books", text: $state.seachText)
                    .focused($focus, equals: .searchText)
                    .keyboardType(.webSearch)
                    .abeeFont(size: 14, style: .italic)
                    
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .onTapGesture {
                focus = .searchText
            }
            .onChange(of: focus) { oldValue, newValue in
                withAnimation {
                    isShowSearchIcon = newValue != .searchText
                }
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
            List {
                ForEach(state.books) { book in
                    BookCell(book: book)
                        .onTapGesture {
                            store.receive(action: .gotoDetail(book: book))
                        }
                        .onAppear() {
                            guard book == state.books.last && !state.isLoadingMore else { return }
                            store.receive(action: .loadmoreBooks)
                        }
                }
                .onDelete { indexSet in
                    store.receive(action: .swipeDelete(atOffsets: indexSet))
                }

                if state.isLoadingMore {
                    ProgressView()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, maxHeight: 20)
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
#Preview(traits: .modifier(PersistentContainerPreviewModifier())) {
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
#Preview {
    
    @Previewable @State var state = HomeScreen.HomeState()
    VStack {
        HomeScreen.SearchBody(state: state)
            
    }
    .frame(maxHeight: .infinity)
    .background(Color.gray)
}
