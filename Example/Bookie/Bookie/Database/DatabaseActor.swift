//
//  DatabaseActor.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import SwiftData
import Foundation

@DatabaseActor
func databaseWriteTransaction(models: [any PersistentModel],
                              useContext context: ModelContext) async throws {
    
    if models.count > 1300 {
        let batches = models.chunked(into: 1000)
        for batch in batches {
            for model in batch {
                context.insert(model)
            }
            try context.save()
            let ids = batch.map(\.persistentModelID)
            await DatabaseActor.shared.produce(changes: .addNewOrUpdate(ids))
            let count = await DatabaseActor.jobCount
            if count > 1 {
                try await Task.sleep(for: .milliseconds(300))
            }
        }
    } else {
        for model in models {
            context.insert(model)
        }
        try context.save()
        let ids = models.map(\.persistentModelID)
        await DatabaseActor.shared.produce(changes: .addNewOrUpdate(ids))
    }
}

@DatabaseActor
func databaseDeleteTransaction(models: [any PersistentModel],
                               useContext context: ModelContext) async throws {
    for model in models {
        guard !model.isDeleted else { continue }
        context.delete(model)
    }
    try context.save()
    let ids = models.map( \.persistentModelID)
    await DatabaseActor.shared.produce(changes: .deleted(ids))
}

//MARK: - DatabaseActor
@globalActor
public actor DatabaseActor {
    
    public static let shared = DatabaseActor()
    private static let executer = DatabseExecutor()
    private let producer = ProduceStream()
    
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        Self.sharedUnownedExecutor
    }
    
    public static var sharedUnownedExecutor: UnownedSerialExecutor {
        executer.asUnownedSerialExecutor()
    }
    
    static var jobCount: Int {
        get async {
            await executer.jobCounter.jobCount
        }
    }

    private init() { }
}

extension DatabaseActor {
    
    nonisolated var changesStream: AsyncStream<DidSaveChangesResult> {
        get async {
            await producer.stream
        }
    }
    
    nonisolated func produce(changes: DidSaveChangesResult) async {
        await producer.produce(changes: changes)
    }
}

//MARK: - DatabseExecutor
fileprivate final class DatabseExecutor: SerialExecutor {
    
    private let queue = DatabaseQueue()
    
    var jobCounter: JobCounter {
        queue.counter
    }
    
    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        let executer = asUnownedSerialExecutor()
        queue.asyncJob {
            unownedJob.runSynchronously(on: executer)
        }
    }
    
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

//MARK: - DatabaseQueue
fileprivate final class DatabaseQueue: @unchecked Sendable {
    
    let counter = JobCounter()
    private let queue =  DispatchQueue(label: "com.database.DatabaseActor")
    
    func asyncJob(execute work: @escaping @Sendable @convention(block) () -> Void) {
        counter.increase()
        queue.async {[weak self] in
            work()
            self?.counter.decrease()
        }
    }
}

//MARK: - Produce Stream
fileprivate actor ProduceStream {
    
    typealias Element = DatabaseActor.DidSaveChangesResult
    typealias Continuation = AsyncStream<Element>.Continuation
    
    private var continuations: [String:Continuation] = [:]

    /// Events stream
    var stream: AsyncStream<Element> {
        AsyncStream { continuation in
            append(continuation)
        }
    }

    private func append(_ continuation: Continuation) {
        let key = UUID().uuidString
        continuation.onTermination  = {[weak self] _ in
            self?.onTermination(forKey: key)
        }
        continuations.updateValue(continuation, forKey: key)
    }
    
    private func removeContinuation(forKey key: String) {
        continuations.removeValue(forKey: key)
    }

    func produce(changes: Element) {
        continuations.values.forEach({ $0.yield(changes) })
    }

    func finishChangesStream() {
        continuations.values.forEach({ $0.finish() })
        continuations.removeAll()
    }
    
    nonisolated private func onTermination(forKey key: String) {
        Task(priority: .high) {
            await removeContinuation(forKey: key)
        }
    }
}

//MARK: - Helpers
extension DatabaseActor {
    
    enum DidSaveChangesResult: Sendable {
        case addNewOrUpdate([PersistentIdentifier])
        case deleted([PersistentIdentifier])
    }
}

fileprivate actor JobCounter {
    
    private(set) var jobCount: Int = 0
    
    private func _inscrease() {
        jobCount += 1
    }
    
    private func _descrease() {
        jobCount -= 1
    }
    
    nonisolated func increase() {
        Task(priority: .high) {
            await _inscrease()
        }
    }
    
    nonisolated func decrease() {
        Task(priority: .high) {
            await _descrease()
        }
    }
}

extension Array {
    fileprivate func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}


