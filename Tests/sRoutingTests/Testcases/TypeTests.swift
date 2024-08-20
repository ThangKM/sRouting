//
//  TypeTests.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import Foundation
import SwiftUI

import XCTest

@testable import sRouting

class TypeTests: XCTestCase {
    
    
    @MainActor
    func testAnyRoute() async throws {
        let route = AnyRoute(route: HomeRoute.home)
        let condition = route.path.contains(HomeRoute.home.path)
        XCTAssertTrue(condition)
        XCTAssertNotNil(route.screen)
    }
    
    func testSRRoutingError() async throws {
        let error = SRRoutingError.unsupportedDecodable
        XCTAssertTrue(error.errorCode < .zero)
        XCTAssertEqual(error.localizedDescription, error.description)
        XCTAssertEqual(SRRoutingError.errorDomain, "com.srouting")
    }
}



