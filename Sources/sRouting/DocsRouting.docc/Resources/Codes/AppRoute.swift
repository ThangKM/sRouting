//
//  AppRoute.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting


enum AppRoute: SRRoute {
    
    case startScreen
    case homeScreen
    
    var path: String {
        switch self {
        case .startScreen: return "startscreen"
        case .homeScreen: return "homescreen"
        }
    }
    
    var screen: some View {
        switch self {
        case .startScreen: StartScreen()
        case .homeScreen: HomeScreen()
        }
    }
}
