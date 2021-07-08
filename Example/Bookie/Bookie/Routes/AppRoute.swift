//
//  AppRoute.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting


enum AppRoute: Route {
    
    case startScreen
    case homeScreen
    
    var screen: some View {
        switch self {
        case .startScreen: StartScreen()
        case .homeScreen: HomeScreen()
        }
    }
}
