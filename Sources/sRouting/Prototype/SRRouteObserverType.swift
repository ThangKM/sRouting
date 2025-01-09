//
//  SRRouteObserverType.swift
//
//
//  Created by Thang Kieu on 19/8/24.
//

import Foundation
import SwiftUI

public protocol SRRouteObserverType: ViewModifier {
    init()
}

extension View {
    
    public func routeObserver<Observer>(_ observer: Observer.Type) -> some View where Observer: SRRouteObserverType {
        modifier(observer.init())
    }
}
