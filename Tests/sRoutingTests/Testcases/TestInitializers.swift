//
//  TestInitializers.swift
//  
//
//  Created by ThangKieu on 7/1/21.
//

import XCTest
import ViewInspector
import SwiftUI

@testable import sRouting

class TestInitializers: XCTestCase {

    override class func setUp() {
        super.setUp()
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
    func testInitScreenView() throws {
        DispatchQueue.main.async {
            let view = NavigationView {  BlueScreen() }
            let text = try view.inspect().find(text: "TextInBlueScreen").string()
            XCTAssertEqual(text, "TextInBlueScreen")
        }
    }
}

extension ScreenView : Inspectable { }
