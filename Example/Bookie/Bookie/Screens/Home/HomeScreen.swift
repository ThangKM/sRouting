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
    @State private var store = HomeStore()
    @State private var state = HomeState()
    
    @Environment(MockBookData.self) private var mockData
    

    var body: some View {
        BookieNavigationView(title: "My Book List",
                             router: router,
                             isBackType: false) {
            VStack {
                
                SearchBody(state: state)

                Text("BOOKS REVIEWED BY YOU")
                    .abeeFont(size: 12, style: .italic)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ListBookBody(state: state, router: router)
            }
            .refreshable {
                store.receive(action: .updateAllBooks(books: mockData.books))
            }
            
        }
         .onChange(of: state.seachText, { oldValue, newValue in
             withAnimation {
                 store.receive(action: .findBooks(text: newValue))
             }
             
         })
         .onChange(of: mockData.books) { _, newValue in
             store.receive(action: .updateAllBooks(books: newValue))
             store.receive(action: .findBooks(text: state.seachText))
         }
         .task {
             store.binding(state: state)
             store.receive(action: .updateAllBooks(books: mockData.books))
         }
    }
}

//MARK: - SearchBody
extension HomeScreen {
    
    fileprivate struct SearchBody: View {
        
        @Bindable var state: HomeState
        
        var body: some View {
            Group {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .opacity(0.4)
                    TextField("Search books", text: $state.seachText)
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
        }
    }
}

//MARK: - ListBookBody
extension HomeScreen {
    
    fileprivate struct ListBookBody: View {
        
        let state: HomeState
        let router: SRRouter<HomeRoute>
        
        var body: some View {
            List(state.books) { book in
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
}

private struct StatePreviewProvider: PreviewModifier {
    
    static func makeSharedContext() async throws -> HomeScreen.HomeState {
        let state = HomeScreen.HomeState()
        state.updateAllBooks(books: MockBookData().books)
        return state
    }
    
    func body(content: Content, context: HomeScreen.HomeState) -> some View {
        content.environment(context)
    }
    
}

//MARK: - Preview
@available(iOS 18.0, *)
#Preview(traits: .modifier(MockBookPreviewProvider())) {
    HomeScreen()
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(StatePreviewProvider())) {
    
    @Previewable @State var router = SRRouter(HomeRoute.self)
    @Previewable @Environment(HomeScreen.HomeState.self) var state

    BookieNavigationView(title: "List Books", router: router, isBackType: false) {
        HomeScreen.ListBookBody(state: state, router: router)
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(StatePreviewProvider())) {
    
    @Previewable @Environment(HomeScreen.HomeState.self) var state
    VStack {
        HomeScreen.SearchBody(state: state)
            
    }
    .frame(maxHeight: .infinity)
    .background(Color.gray)
}
