//
//  StartScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

struct StartScreen: View {
    
    let startAction: AsyncActionPut<Bool>
    
    var body: some View {
        ZStack {
            BackgroundBubleBody()
            MainBody(startAction: startAction)
        }
        .navigationBarHidden(true)
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
        
        let startAction: AsyncActionPut<Bool>
        
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
                    Task {
                        try await startAction.execute(true)
                    }
                } label: {
                    Text("Start")
                        .foregroundColor(.accentColor)
                        .underline()
                        .abeeFont(size: 16, style: .italic)
                }.padding(.init(top: 30, leading: 0, bottom: 30, trailing: 0))
            }
        }
    }
}
    
#Preview {
    StartScreen(startAction: .init({ _ in
        
    }))
}

#Preview {
    StartScreen.BackgroundBubleBody()
}

#Preview {
    StartScreen.MainBody(startAction: .init({ _ in
        
    }))
}
