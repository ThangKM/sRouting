//
//  TestScreen.swift
//  
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI
import ViewInspector
import Testing

@testable import sRouting

struct TestScreen: View {
    
    let router: TestRouter
    let tests: UnitTestActions<RouterModifier<TestRouter>>?
    
    var body: some View {
        Text("TestScreen.Screen.Text")
            .onRouting(of: router, tests: tests)
    }
}


