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
    
    @Environment(\.dismiss)
    private var dismissAction
    
    let router: TestRouter
    let tests: UnitTestActions<ScreenView<Text,TestRouter>>?
    
    var body: some View {
        ScreenView(router: router, dismissAction: dismissAction, tests: tests) {
            Text("TestScreen.ScreenView.Text")
        }
    }
}
