//
//  AppRoute.swift
//  Bookie
//
//  Created by ThangKieu on 7/6/21.
//

import SwiftUI
import sRouting


enum AppRoute: SRRoute {
    
    case startScreen(startAction: AsyncActionPut<Bool>)
    case homeScreen
    
    var path: String {
        switch self {
        case .startScreen: return "startScreen"
        case .homeScreen: return "homeScreen"
        }
    }
    
    var screen: some View {
        switch self {
        case .startScreen(let action): StartScreen(startAction: action)
        case .homeScreen: HomeScreen()
        }
    }
}
