//
//  BookieNavigationView.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting

struct BookieNavigationView<Content, RouteType>: View where Content: View, RouteType: Route {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    let title: String
    
    @ObservedObject
    var router: Router<RouteType>
    
    let isBackType: Bool
    
    @ViewBuilder
    let content: Content
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                LinearGradient(colors: [Color("purple.F66EB4"), Color("orgrian.FEB665")], startPoint: .leading, endPoint: .trailing)
                    .frame(height: 152)
                    .clipShape(Ellipse().path(in: .init(x:-((787 - geo.size.width)/2), y: -210/2, width: 787, height: 239)))
            }
            .clipped()
            .edgesIgnoringSafeArea(.top)
            
            VStack {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .abeeFont(size: 19, style: .italic)
                    .frame(height: 44)
                    .overlay(
                        Image("ic.navi.back")
                            .frame(width: 24)
                            .opacity( isBackType ? 1 : 0)
                            .onTapGesture {
                        router.dismiss()
                    },
                        alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                ScreenView(router: router, presentationMode: presentationMode) {
                    content
                }
                Spacer()
            }
        }
        .background(Color("backgournd.EEECFF"))
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
    }
}

struct BookieNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        BookieNavigationView<Text, HomeRoute>(title: "Navigation Title", router: .init(), isBackType: true) {
            Text("")
        }.environmentObject(RootRouter())
    }
}
