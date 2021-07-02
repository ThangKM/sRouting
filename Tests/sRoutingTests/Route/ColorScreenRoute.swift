//
//  ColorScreenRoute.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
@testable import sRouting

enum EmptypeRoute: Route {
    
    case emptyScreen
    
    var screen: some View {
        EmptyView()
    }
}
