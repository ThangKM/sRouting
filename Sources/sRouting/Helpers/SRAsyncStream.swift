//
//  SRAsyncStream.swift
//
//
//  Created by Thang Kieu on 9/4/24.
//

import Foundation

public actor SRAsyncStream<Value> where Value: Sendable {
    
    typealias Continuation = AsyncStream<Value>.Continuation
    
    private var continuations: [Continuation] = []
    private let defaultValue: Value
    private(set) var currenValue: Value
    
    public init(defaultValue: Value) {
        self.currenValue = defaultValue
        self.defaultValue = defaultValue
    }
    
    /// Events stream
    public var stream: AsyncStream<Value> {
        AsyncStream { continuation in
            append(continuation)
        }
    }
    
    private func append(_ continuation: Continuation) {
        continuations.append(continuation)
    }
    
    public func emit(_ value: Value) {
        currenValue = value
        continuations.forEach({ $0.yield(currenValue) })
    }
    
    public func reset() {
        emit(defaultValue)
    }
    
    public func finish() {
        currenValue = defaultValue
        continuations.forEach({ $0.finish() })
        continuations.removeAll()
    }
}

extension SRAsyncStream where Value == Int {
    
    public func increase() {
        currenValue += 1
        emit(currenValue)
    }
    
    public func decrease() {
        currenValue -= 1
        emit(currenValue)
    }
}
