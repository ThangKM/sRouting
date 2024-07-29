//
//  AppRouter.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import SwiftUI
import sRouting
import Observation

@Observable
final class AppRouter {
    
    @ObservationIgnored @AppStorage("didTutorial")
    private var didTutorial: Bool = false
    
    var rootRoute: AppRoute {
        get {
            access(keyPath: \.rootRoute)
            return _rootRoute
        }
        
        set {
            withMutation(keyPath: \.rootRoute) {
                _rootRoute = newValue
            }
        }
    }
    
    @ObservationIgnored private lazy var _rootRoute: AppRoute = didTutorial ? .homeScreen : .startScreen
}
