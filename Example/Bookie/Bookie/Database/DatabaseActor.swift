//
//  DatabaseActor.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import SwiftData
import Foundation
import sRouting

@DatabaseActor
func databaseInsertTransaction(models: [any PersistentModel],
                              useContext context: ModelContext) async throws {
    guard let lastModel = models.last else { return }
    assert(context.createtor == "DatabaseActor" || EnvironmentRunner.current == .livePreview,
           "use ModelContext.isolatedContext to create the context with DatabaseActor isolation")
    
    let count = models.count
    var insertedModels: [any PersistentModel] = .init()
    
    for model in models {
        autoreleasepool {
            context.insert(model)
            insertedModels.append(model)
        }
        if insertedModels.count >= 1000 || model.persistentModelID == lastModel.persistentModelID {
            try context.save()
            let insertedIds = insertedModels.map(\.persistentModelID)
            await DatabaseActor.shared.produce(changes: .insertedIdentifiers(insertedIds))
            insertedModels.removeAll()
        }
        try? await prevent_huge_loop(count: count)
    }
}

@DatabaseActor
func databaseUpdateTransaction(models: [any PersistentModel],
                               useContext context: ModelContext) async throws {
    guard !models.isEmpty else { return }
    assert(context.createtor == "DatabaseActor" || EnvironmentRunner.current == .livePreview,
           "use ModelContext.isolatedContext to create the context with DatabaseActor isolation")
    try context.save()
    let ids = models.map(\.persistentModelID)
    await DatabaseActor.shared.produce(changes: .updatedIdentifiers(ids))
}

@DatabaseActor
func databaseDeleteTransaction(models: [any PersistentModel],
                               useContext context: ModelContext) async throws {
    guard !models.isEmpty else { return }
    assert(context.createtor == "DatabaseActor" || EnvironmentRunner.current == .livePreview,
           "use ModelContext.isolatedContext to create the context with DatabaseActor isolation")

    for model in models {
        guard !model.isDeleted else { continue }
        context.delete(model)
    }
    let ids = models.map(\.persistentModelID)
    await DatabaseActor.shared.produce(changes: .deletedIdentifiers(ids))
    try context.save()
}

//MARK: - DatabaseActor
@globalActor
public actor DatabaseActor {
    
    public static let shared = DatabaseActor()
    private static let executer = DatabseExecutor()
    private let changesProducer = ProduceStream()
    
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        Self.sharedUnownedExecutor
    }
    
    public static var sharedUnownedExecutor: UnownedSerialExecutor {
        executer.asUnownedSerialExecutor()
    }
    
    private init() { }
}

extension DatabaseActor {
    
    nonisolated var changesStream: AsyncStream<PersistentModelChangesResult> {
        get async {
            await changesProducer.stream
        }
    }
    
    nonisolated fileprivate func produce(changes: PersistentModelChangesResult) async {
        await changesProducer.produce(changes: changes)
    }
}

//MARK: - DatabseExecutor
fileprivate final class DatabseExecutor: SerialExecutor {
    
    private let queue = DatabaseQueue()
    
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
    
    private let queue =  DispatchQueue(label: "com.database.DatabaseActor")
    
    func asyncJob(execute work: @escaping @Sendable @convention(block) () -> Void) {
        queue.async {
            work()
        }
    }
}

//MARK: - Produce Stream
fileprivate actor ProduceStream {
    
    typealias Element = DatabaseActor.PersistentModelChangesResult
    typealias Continuation = AsyncStream<Element>.Continuation
    
    private var continuations: [String:Continuation] = [:]
    private let cancelBag = CancelBag()
    
    /// Events stream
    var stream: AsyncStream<Element> {
        AsyncStream { continuation in
            append(continuation)
        }
    }
    
    deinit {
        cancelBag.cancelAllInTask()
    }

    func produce(changes: Element) {
        continuations.values.forEach({ $0.yield(changes) })
    }

    func finishChangesStream() {
        continuations.values.forEach({ $0.finish() })
        continuations.removeAll()
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

    nonisolated private func onTermination(forKey key: String) {
        Task(priority: .high) {
            await removeContinuation(forKey: key)
        }
    }
}

//MARK: - Helpers
extension DatabaseActor {
    
    enum PersistentModelChangesResult: Sendable {
        case insertedIdentifiers([PersistentIdentifier])
        case deletedIdentifiers([PersistentIdentifier])
        case updatedIdentifiers([PersistentIdentifier])
    }
}

extension ModelContext {
    
    static var isolatedContext: ModelContext {
        DatabaseActor.assertIsolated("Handle ModelContext outside of DatabaseActor, Use @DatabaseActor to islolated the flow")
        let context = ModelContext(DatabaseProvider.shared.container)
        context.createtor = "DatabaseActor"
        return context
    }
    
    static var fetchContext: ModelContext {
        ModelContext(DatabaseProvider.shared.container)
    }
    
    struct AsociationKey {
        nonisolated(unsafe) static var creatorKey: UInt8 = 0
    }
    
    fileprivate var createtor: String? {
        get {
            objc_getAssociatedObject(self, &AsociationKey.creatorKey) as? String
        }
        
        set {
            objc_setAssociatedObject(self,
                                     &AsociationKey.creatorKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

func prevent_huge_loop(count: Int) async throws {
    guard count > 10_000 else { return }
    try await Task.sleep(for: .microseconds(5))
}
