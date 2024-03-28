//
//  EmptyRoute.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import SwiftUI
@testable import sRouting


@sRouter(EmptyRoute.self) @Observable
class TestRouter { }

enum EmptyRoute: SRRoute {
    
    case emptyScreen
    
    var screen: some View {
        EmptyView()
    }
}

