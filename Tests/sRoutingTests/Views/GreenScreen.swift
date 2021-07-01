//
//  GreenScreen.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
@testable import sRouting

struct GreenScreen: View {
    @StateObject
    private var router = Router<ColorScreenRoute>()
    
    var body: some View {
        ScreenView(router: router) {
            Text("GreenScreen")
                .onTapGesture {
                    router.trigger(to: .redScreen, with: .present)
            }
        }
    }
}
