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
    
    let router: TestRouter
    let tests: UnitTestActions<RouterModifier<TestRouter>>?
    
    var body: some View {
        Text("TestScreen.ScreenView.Text")
            .onRouting(of: router, tests: tests)
    }
}
