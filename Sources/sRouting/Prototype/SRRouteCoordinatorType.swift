//
//  SRRouteCoordinatorType.swift
//
//
//  Created by Thang Kieu on 02/04/2024.
//

import Foundation

@MainActor
public protocol SRRouteCoordinatorType: AnyObject {
    
    var identifier: String { get }
    var rootRouter: SRRouter<AnyRoute> { get }
    var emitter: SRCoordinatorEmitter { get }
    var navigationStacks: [SRNavigationPath] { get }
    var activeNavigation: SRNavigationPath? { get }
    
    func registerActiveNavigation(_ navigationPath: SRNavigationPath)
}
