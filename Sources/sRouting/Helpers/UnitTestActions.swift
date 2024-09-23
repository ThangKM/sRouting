//
//  UnitTestActions.swift
//  
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI

/// The test callbacks action of navigator views
struct UnitTestActions<TargetView>
where TargetView: ViewModifier {
    typealias ViewReturnAction = (TargetView) -> Void
    var didChangeTransition: ViewReturnAction?
}
