//
//  ColorScreenRoute.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
@testable import sRouting

enum ColorScreenRoute: Route {
    
    case blueScreen
    case redScreen
    case greenScreen
    
    var screen: some View {
        switch self {
        case .blueScreen: BlueScreen()
        case .redScreen: RedScreen()
        case .greenScreen: GreenScreen()
        }
    }
}
