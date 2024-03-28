//
//  File.swift
//  
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI

/// The test callbacks action of navigator views
struct UnitTestActions<TargetView>
where TargetView: View {
    
    typealias ViewReturnAction = (TargetView) -> Void
    typealias VoidAction = () -> Void
    
    var didChangeTransition: ViewReturnAction?
    var didAppear: ViewReturnAction?
    var resetActiveState: ViewReturnAction?
    var dismissAction: VoidAction?
}
