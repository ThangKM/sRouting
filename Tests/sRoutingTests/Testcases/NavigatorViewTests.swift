//
//  NavigatorViewTests.swift
//  
//
//  Created by ThangKieu on 7/2/21.
//

import SwiftUI
import ViewInspector
@testable import sRouting
import XCTest

class NavigatorViewTests: XCTestCase {
    
    func testPush() throws {
        @ObservedObject
        var router = Router<EmptypeRoute>()
        let _ = NavigatorView(router: router) { type in
            XCTAssertTrue(type == .push)
        }
        router.trigger(to: .emptyScreen, with: .push)
    }
    
    func testPresentFullScreen() {
        let router = Router<EmptypeRoute>()
        let _ = NavigatorView(router: router) { type in
            XCTAssertTrue(type == .present)
        }
        router.trigger(to: .emptyScreen, with: .present)
    }

    func testSheet() {
        let router = Router<EmptypeRoute>()
        let _ = NavigatorView(router: router) { type in
            XCTAssertTrue(type == .sheet)
        }
        router.trigger(to: .emptyScreen, with: .sheet)
    }

    func testAlert() {
        let router = Router<EmptypeRoute>()
        let _ = NavigatorView(router: router) { type in
            XCTAssertTrue(type == .alert)
        }
        router.show(alert: .init(title: Text(""), message: nil, dismissButton: nil))
    }

    func testDismiss() {
        let router = Router<EmptypeRoute>()
        let _ = NavigatorView(router: router) {
            XCTAssertTrue(true)
        }
        router.dismiss()
    }
}
