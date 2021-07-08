//
//  StartScreen.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

struct StartScreen: View {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    @StateObject
    private var router: Router<AppRoute> = .init()
    
    @EnvironmentObject
    private var appRouter: AppRouter
    
    var body: some View {
        ScreenView(router: router, presentationMode: presentationMode) {
            ZStack {
        
                GeometryReader { geo in
                    VStack {
                        RandomBubbleView(bubbles: [[Color("orgrian.FEB665"), Color("purple.F66EB4")],
                                                   [Color("cyan.2DEEF9"), Color("purple.F66EB4")],
                                                  ], minWidth: 40, maxWidth: 120)
                            .opacity(.random(in: 0.5...0.7))
                            .frame(width: geo.size.width , height: geo.size.height / 2)
                        
                        Spacer()
                        
                        RandomBubbleView(bubbles: [[Color("cyan.2DEEF9"), Color("purple.F66EB4")]], minWidth: 200, maxWidth: 300)

                            .opacity(.random(in: 0.1...0.3))
                            .frame(width: geo.size.width, height: 100)
                    }
                }
                .ignoresSafeArea()
                
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
                        appRouter.rootRoute = .homeScreen
                    } label: {
                        Text("Start")
                            .foregroundColor(.accentColor)
                            .underline()
                            .abeeFont(size: 16, style: .italic)
                    }.padding(.init(top: 30, leading: 0, bottom: 30, trailing: 0))
                    
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
    }
}
