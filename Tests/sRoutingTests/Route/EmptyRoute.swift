//
//  EmptyRoute.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
@testable import sRouting

enum EmptyRoute: Route {
    
    case emptyScreen
    
    var screen: some View {
        EmptyView()
    }
}
