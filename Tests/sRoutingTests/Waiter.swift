//
//  Waiter.swift
//  sRouting
//
//  Created by Thang Kieu on 25/9/24.
//

import Foundation
import XCTest

struct TimeOutError: Error, CustomStringConvertible {
    var description: String { "time out" }
}

final class Waiter: @unchecked Sendable {

    private let exp = XCTestExpectation()
    
    @discardableResult
    func await(for timeout: TimeInterval) async throws -> Bool {
        try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let `self` else {
                continuation.resume(throwing: TimeOutError())
                return
            }
            let result = XCTWaiter.wait(for: [exp], timeout: timeout)
            switch result {
            case .completed:
                continuation.resume(returning: true)
            default :
                continuation.resume(throwing: TimeOutError())
            }
        }
    }
    
    func finish() {
        exp.fulfill()
    }
}
