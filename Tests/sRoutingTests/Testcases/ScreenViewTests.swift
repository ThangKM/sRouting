//
//  ScreenViewTests.swift
//  
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI
import XCTest
import ViewInspector
@testable import sRouting

class ScreenViewTests: XCTestCase {
    
    @MainActor
    func testDismissAction() async {
        let exp = XCTestExpectation()
        let router = TestRouter()
        let view = TestScreen(router: router, tests: .init(
            dismissAction: {
            exp.fulfill()
        }))
        ViewHosting.host(view: view)
        router.dismiss()
        await fulfillment(of: [exp], timeout: 0.2)
    }
}
