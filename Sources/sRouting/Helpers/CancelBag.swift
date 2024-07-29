//
//  CancelBag.swift
//
//
//  Created by Thang Kieu on 9/4/24.
//

import Foundation

final class CancelBag: @unchecked Sendable {
    
    private let island = Island()
    
    func cancelAll() {
        Task(priority: .high) {
            await island.cancelAll()
        }
    }
    
    func cancel(forIdentifier identifier: String) {
        Task(priority: .high) {
            await island.cancel(forIdentifier:identifier)
        }
    }
    
    fileprivate func append(canceller: Canceller) {
        Task(priority: .high) {
            await island.append(canceller:canceller)
        }
    }
}

private extension CancelBag {

    actor Island {
        
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
        
        func append(canceller: Canceller) {
            cancellers.updateValue(canceller, forKey: canceller.id)
        }
    }
}

private struct Canceller: Identifiable {
    let cancel: () -> Void
    let id: String
    var isCancelled: Bool { isCancelledBock() }
    
    private let isCancelledBock: () -> Bool
    
    init<S,E>(_ task: Task<S,E>, identifier: String = UUID().uuidString) {
        cancel = task.cancel
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
