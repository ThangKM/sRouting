//
//  Database.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import Foundation
import SwiftData

final class Database: Sendable {
    
    static let shared = Database()
    let container: ModelContainer
    
    private init() {
        switch EnvironmentRunner.current {
        case .livePreview:
            do {
                let config = ModelConfiguration(for: BookPersistent.self, isStoredInMemoryOnly: true)
                container = try ModelContainer(for: BookPersistent.self, configurations: config)
            } catch {
                fatalError("Failed to initialize database: \(error)")
            }
        default:
            do {
                container = try ModelContainer(for: BookPersistent.self)
            } catch {
                fatalError("Failed to initialize database: \(error)")
            }
        }
    }
}

@globalActor
public actor PersistentActor {
    
    static public let shared = PersistentActor()
    private static let executer = DatabseExecutor()
    
    static var jobCount: Int {
        get async {
            await executer.jobCounter.jobCount
        }
    }
    
    private init() { }
    
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        Self.sharedUnownedExecutor
    }
    
    public static var sharedUnownedExecutor: UnownedSerialExecutor {
        executer.asUnownedSerialExecutor()
    }
}

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

@PersistentActor
func persistentWriteTransaction(models: [any PersistentModel],
                                useContext context: ModelContext) async throws {
    
    if models.count > 1300 {
        let batches = models.chunked(into: 1000)
        for batch in batches {
            for model in batch {
                context.insert(model)
            }
            try context.save()
            let count = await PersistentActor.jobCount
            if count > 1 {
                try await Task.sleep(for: .milliseconds(300))
            }
        }
    } else {
        for model in models {
            context.insert(model)
        }
        try context.save()
    }
}

extension Array {
    fileprivate func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

fileprivate final class DatabaseQueue: @unchecked Sendable {
    
    let counter = JobCounter()
    private let queue =  DispatchQueue(label: "com.database.PersistentActor")
    
    func asyncJob(execute work: @escaping @Sendable @convention(block) () -> Void) {
        counter.increase()
        queue.async {[weak self] in
            work()
            self?.counter.decrease()
        }
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
