//
//  AppRouter.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import SwiftUI
import sRouting

@MainActor
class AppRouter: RootRouter {

    @Published var rootRoute: AppRoute = .startScreen
}
