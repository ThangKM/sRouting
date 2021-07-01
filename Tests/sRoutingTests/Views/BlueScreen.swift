//
//  BlueScreen.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
import ViewInspector
@testable import sRouting

struct BlueScreen: View {
    @StateObject
    private var router = Router<ColorScreenRoute>()
    
    var body: some View {
        ScreenView(router: router) {
            Text("TextInBlueScreen")
                .onTapGesture {
                    router.trigger(to: .greenScreen, with: .push)
            }
        }
    }
}

extension BlueScreen: Inspectable { }
