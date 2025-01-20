//
//  StartScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

struct StartScreen: View {
    
    @State private var store: StartStore
    @State private var state = StartState()
    @State private var router = SRRouter(AppAlertsRoute.self)

    init(store: StartStore) {
        self._store = .init(initialValue: store)
    }
    
    var body: some View {
        ZStack {
            BackgroundBubleBody()
            MainBody(state: state, store: store)
        }
        .navigationBarHidden(true)
        .task {
            store.binding(state: state, router: router)
        }
    }
}

//MARK: - BackgroundBubleBody
extension StartScreen {
    
    fileprivate struct BackgroundBubleBody: View {
        
        var body: some View {
            VStack {
                RandomBubbleView(bubbles: [[Color("orgrian.FEB665"), Color("purple.F66EB4")],
                                           [Color("cyan.2DEEF9"), Color("purple.F66EB4")],
                                          ], minWidth: 40, maxWidth: 120)
                    .opacity(.random(in: 0.5...0.7))
                    .containerRelativeFrame(.vertical, count: 5, span: 2, spacing: .zero)
                
                Spacer()
                    .containerRelativeFrame(.vertical, count: 5, span: 1, spacing: .zero)
                
                RandomBubbleView(bubbles: [[Color("cyan.2DEEF9"), Color("purple.F66EB4")]], minWidth: 200, maxWidth: 300)
                    .opacity(.random(in: 0.1...0.3))
                    .containerRelativeFrame(.vertical, count: 5, span: 2, spacing: .zero)
            }
        }
    }
}

//MARK: - MainBody
extension StartScreen {
    
    fileprivate struct MainBody: View {
        
        @Bindable var state: StartState
        let store: StartStore
        
        var body: some View {
            VStack(alignment: .center) {
                
                Spacer()
                
                Image("start.book.circle")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.8)
                
                VStack {
                    Text("Read Books")
                        .abeeFont(size: 33, style: .italic)
                        .foregroundColor(.accentColor)
                    Text("Become a Bookie")
                        .abeeFont(size: 14, style: .italic)
                        .foregroundColor(.accentColor)
                }
                
                Spacer()

                Button {
                    store.receive(action: .startAction)
                } label: {
                    TextLoadingView(isLoading: state.isLoading, text: "Start")
                        .foregroundColor(.accentColor)
                        .underline()
                        .abeeFont(size: 16, style: .italic)
                }
                .disabled(state.isLoading)
                .padding(.init(top: 30, leading: 0, bottom: 30, trailing: 0))
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(PersistentContainerPreviewModifier())) {
    StartScreen(store: .init(showHomeAction: .init({ _ in
        
    })))
}

#Preview {
    StartScreen.BackgroundBubleBody()
}

#Preview {
    StartScreen.MainBody(state: .init(), store: .init(showHomeAction: .init({ _ in
        
    })))
}
