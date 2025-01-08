//
//  Publishers.OnChanges.swift
//  sRouting
//
//  Created by Thang Kieu on 7/1/25.
//

import Combine

extension Publishers {
    struct OnChanges<UpStream: Publisher>: Publisher
    where UpStream.Output: Equatable  {
        
        typealias Output = UpStream.Output
        typealias Failure = UpStream.Failure
        
        private let upstream: UpStream
        init(upstream: UpStream) {
            self.upstream = upstream
        }
        
        func receive<S>(subscriber: S)
        where S : Subscriber, UpStream.Failure == S.Failure, UpStream.Output == S.Input {
            
        }
    }
}

extension Publishers.OnChanges {
    
    final class Inner<DownStream: Subscriber>: Subscriber
    where DownStream.Input == UpStream.Output, DownStream.Failure == UpStream.Failure {
        typealias Input = UpStream.Output
        
        typealias Failure = UpStream.Failure
        private let downstream: DownStream
        private var current: Input?
        
        init(downstream: DownStream) {
            self.downstream = downstream
        }
        
        func receive(subscription: any Subscription) {
            downstream.receive(subscription: subscription)
        }
        
        func receive(_ input: UpStream.Output) -> Subscribers.Demand {
            guard input != current else { return .max(1) }
            current = input
            return downstream.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<UpStream.Failure>) {
            downstream.receive(completion: completion)
        }
    }
}

extension Publisher where Self.Output: Equatable {
    func onChanges() -> Publishers.OnChanges<Self> {
        .init(upstream: self)
    }
}
