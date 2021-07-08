//
//  File.swift
//  
//
//  Created by ThangKieu on 7/8/21.
//

import XCTest
import ViewInspector
import SwiftUI
@testable import sRouting

struct InitScreenView: View, Inspectable {
    
    @Environment(\.presentationMode) private var presentationMode
    let router = Router<EmptyRoute>()
    
    var body: some View {
        NavigationView {
            ScreenView(router: router, presentationMode: presentationMode) {
                Text("InitScreenView.ScreenView.Text")
            }
        }
    }
}
