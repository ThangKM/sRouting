//
//  TestScreen.swift
//  
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI
import ViewInspector
@testable import sRouting

struct TestScreen: View {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    let router: Router<EmptyRoute>
    let tests: UnitTestActions<ScreenView<Text,EmptyRoute>,EmptyRoute>
    
    var body: some View {
        ScreenView(router: router, presentationMode: presentationMode, tests: tests) {
            Text("TestScreen.ScreenView.Text")
        }
        .environmentObject(RootRouter())
    }
}
