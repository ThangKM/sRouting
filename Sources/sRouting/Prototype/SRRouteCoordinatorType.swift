//
//  SRRouteCoordinatorType.swift
//
//
//  Created by Thang Kieu on 02/04/2024.
//

import Foundation

@MainActor
public protocol SRRouteCoordinatorType {
    var rootRouter: SRRouter<AnyRoute> { get }
    var dismissAllEmitter: SRDismissAllEmitter { get }
    var tabSelection: SRTabbarSelection { get }
}
