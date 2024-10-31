//
//  SRAsyncStream.swift
//
//
//  Created by Thang Kieu on 9/4/24.
//

import Foundation

actor SRAsyncStream<Value> where Value: Sendable {
    
    typealias Continuation = AsyncStream<Value>.Continuation
    
    private var continuations: [Continuation] = []
    private let defaultValue: Value
    private(set) var currenValue: Value
    
    init(defaultValue: Value) {
        self.currenValue = defaultValue
        self.defaultValue = defaultValue
    }
    
    /// Events stream
    var stream: AsyncStream<Value> {
        AsyncStream { continuation in
            append(continuation)
        }
    }
    
    private func append(_ continuation: Continuation) {
        continuations.append(continuation)
    }
    
    func emit(_ value: Value) {
        currenValue = value
        continuations.forEach({ $0.yield(currenValue) })
    }
    
    func reset() {
        emit(defaultValue)
    }
    
    func finish() {
        currenValue = defaultValue
        continuations.forEach({ $0.finish() })
        continuations.removeAll()
    }
}

extension SRAsyncStream where Value == Int {
    
    func increase() {
        currenValue += 1
        emit(currenValue)
    }
    
    func decrease() {
        currenValue -= 1
        emit(currenValue)
    }
}
