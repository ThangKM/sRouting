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
    
    
    func testDismissAction() {
        let exp = XCTestExpectation()
        let router = TestRouter()
        let view = TestScreen(router: router, tests: .init(
            dismissAction: {
            XCTAssertTrue(true)
            exp.fulfill()
        }))
        ViewHosting.host(view: view)
        router.dismiss()
        wait(for: [exp], timeout: 0.2)
    }
}
