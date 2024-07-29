//
//  IncreaseCountStream.swift
//
//
//  Created by Thang Kieu on 9/4/24.
//

import Foundation

class IncreaseCountStream: @unchecked Sendable {
    
    typealias Continuation = AsyncStream<UInt>.Continuation
    
    private let island: ProtectedIsland
    
    init() {
        self.island = .init()
    }
    /// Events stream
    var stream: AsyncStream<UInt> {
        AsyncStream {[weak self] continuation in
            self?.append(continuation)
        }
    }
    
    private func append(_ continuation: Continuation) {
        Task { await island.append(continuation) }
    }
    
    func resetCount() {
        Task { await island.resetCount() }
    }
    
    func increase() {
        Task { await island.increase() }
    }
    
    func finish() {
        Task { await island.finish() }
    }
}

private extension IncreaseCountStream {
    
    actor ProtectedIsland {
        
        private var continuations: [Continuation] = []
        private var count: UInt = .zero
        
        func append(_ continuation: Continuation) {
            continuations.append(continuation)
        }
        
        func increase() {
            count += 1
            continuations.forEach({ $0.yield(count) })
        }
        
        func resetCount() {
            count = .zero
        }
        
        func finish() {
            count = .zero
            continuations.forEach({ $0.finish() })
            continuations.removeAll()
        }
    }
}
