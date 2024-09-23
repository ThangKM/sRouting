//
//  CancelBag.swift
//
//
//  Created by Thang Kieu on 9/4/24.
//

import Foundation

actor CancelBag {

    private lazy var cancellers: [String:Canceller] = .init()
    
    func cancelAll() {
        let runningTasks = cancellers.values.filter({ !$0.isCancelled })
        runningTasks.forEach{ $0.cancel() }
        cancellers.removeAll()
    }
    
    func cancel(forIdentifier identifier: String) {
        guard let task = cancellers[identifier] else { return }
        task.cancel()
        cancellers.removeValue(forKey: identifier)
    }
    
    private func store(_ canceller: Canceller) {
        if let task = cancellers[canceller.id] {
            task.cancel()
            cancellers.removeValue(forKey: canceller.id)
        }
        cancellers.updateValue(canceller, forKey: canceller.id)
    }
    
    nonisolated fileprivate func append(canceller: Canceller) {
        Task(priority: .high) {
            await store(canceller)
        }
    }
    
    nonisolated func cancelAllInTask() {
        Task(priority: .high) {
            await cancelAll()
        }
    }
}

private struct Canceller: Identifiable, Sendable {
    
    let cancel: @Sendable () -> Void
    let id: String
    var isCancelled: Bool { isCancelledBock() }
    
    private let isCancelledBock: @Sendable () -> Bool
    
    init<S,E>(_ task: Task<S,E>, identifier: String = UUID().uuidString) {
        cancel = { task.cancel() }
        isCancelledBock = { task.isCancelled }
        id = identifier
    }
}

extension Task {
    
    func store(in bag: CancelBag) {
        let canceller = Canceller(self)
        bag.append(canceller: canceller)
    }
    
    func store(in bag: CancelBag, withIdentifier identifier: String) {
        let canceller = Canceller(self, identifier: identifier)
        bag.append(canceller: canceller)
    }
}
