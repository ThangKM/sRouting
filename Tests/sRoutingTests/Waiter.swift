//
//  Waiter.swift
//  sRouting
//
//  Created by Thang Kieu on 21/1/25.
//

import Foundation

struct TimeoutError: CustomNSError, CustomStringConvertible {
    
    static let errorDomain: String = "com.unittesting"
    let errorCode: Int = -408
    let description: String = "Timeout!"
    
    var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: description]
    }
}

actor Waiter {
    
    private var continuation: AsyncThrowingStream<Void,Error>.Continuation?
    
    private lazy var stream: AsyncThrowingStream<Void,Error> = .init {[weak self] continuation in
        self?.continuation = continuation
    }
    
    private var isFinished: Bool = false
    
    var task: Task<Void,Error>?
    
    func waiting(timeout: Duration = .milliseconds(500)) async throws {
        
        guard !isFinished else { return }
        
        task = Task {[weak self] in
            try await Task.sleep(for: timeout)
            try Task.checkCancellation()
            await self?.timeout()
        }
        
        for try await _ in stream { }
    }
    
    nonisolated func fulfill() {
        Task(priority: .high) {
            await finish()
        }
    }
    
    private func timeout() {
        continuation?.finish(throwing: TimeoutError())
        continuation = nil
        isFinished = true
        task = nil
    }
    
    private func finish() {
        continuation?.finish()
        task?.cancel()
        isFinished = true
        continuation = nil
        task = nil
    }
}
