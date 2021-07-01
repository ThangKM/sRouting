//
//  RedScreen.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
@testable import sRouting

struct RedScreen: View {
    @StateObject
    private var router = Router<ColorScreenRoute>()
    
    var body: some View {
        ScreenView(router: router) {
            Text("RedScreen")
                .onTapGesture {
                    router.trigger(to: .blueScreen, with: .sheet)
            }
        }
    }
}
