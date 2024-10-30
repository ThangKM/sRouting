//
//  Waiter.swift
//  sRouting
//
//  Created by Thang Kieu on 25/9/24.
//

import Foundation

struct TimeOutError: Error, CustomStringConvertible {
    var description: String { "time out" }
}

final class Waiter: @unchecked Sendable {

    private var task: Task<Void, Never>?
    
    @discardableResult
    func await(for timeout: Duration) async throws -> Bool {
        try await withCheckedThrowingContinuation {[weak self] continuation in
            self?.task = Task.detached {
                do {
                    try await Task.sleep(for: timeout)
                    continuation.resume(throwing: TimeOutError())
                } catch {
                    continuation.resume(returning: true)
                }
            }
        }
    }
    
    func finish() {
        task?.cancel()
        task = nil
    }
}
