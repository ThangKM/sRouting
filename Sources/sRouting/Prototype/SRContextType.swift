//
//  SRContextType.swift
//
//
//  Created by Thang Kieu on 02/04/2024.
//

import Foundation

@MainActor
public protocol SRContextType {
    associatedtype RouterType: SRRouterType
    
    var rootRouter: RouterType { get }
    var dismissAllEmitter: SRDismissAllEmitter { get }
    var tabSelection: SRTabbarSelection { get }
}
