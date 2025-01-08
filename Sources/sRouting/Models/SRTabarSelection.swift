//
//  SRTabbarSelection.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation

/// Tabbar's selection Observation
@MainActor
public final class SRTabbarSelection: ObservableObject {
    
    @Published
    public var selection: Int = .zero {
        willSet {
            if newValue == selection {
                _increaseTapCount()
                _autoCancelTapCount()
            } else {
                _resetTapCount()
            }
        }
    }
    
    @Published
    var doubleTapEmmiter: SignalChange = false

    nonisolated private let tapCountStream = SRAsyncStream(defaultValue: 0)
    nonisolated private let cancelBag = CancelBag()
    nonisolated private let autoCancelTapIdentifier = "autoCancelTapIdentifier"
    
    public init() {
        _observeTapCountStream()
    }
    
    public func select(tag: Int) {
        selection = tag
    }
    
    private func _emmitDoubleTap() {
        doubleTapEmmiter.toggle()
    }
    
    deinit {
        cancelBag.cancelAllInTask()
    }
}

extension SRTabbarSelection {
    
    nonisolated private func _increaseTapCount() {
        Task(priority: .high) {
            await tapCountStream.increase()
        }
    }
    
    nonisolated private func _resetTapCount() {
        Task(priority: .high) {
            await tapCountStream.reset()
        }
    }
    
    nonisolated private func _observeTapCountStream() {
        Task.detached {[weak self] in
            guard let stream = await self?.tapCountStream.stream,
            let cancelTapId = self?.autoCancelTapIdentifier
            else { return }
            
            for await _ in stream.filter({ $0 == 2 }) {
                try Task.checkCancellation()
                await self?._emmitDoubleTap()
                await self?.tapCountStream.reset()
                await self?.cancelBag.cancel(forIdentifier: cancelTapId)
            }
        }.store(in: cancelBag)
    }

    nonisolated private func _autoCancelTapCount() {
        Task.detached {[weak self] in
            try await Task.sleep(for: .milliseconds(400))
            try Task.checkCancellation()
            await self?.tapCountStream.reset()
            guard let cancelId = self?.autoCancelTapIdentifier else { return }
            await self?.cancelBag.cancel(forIdentifier: cancelId)
        }.store(in: cancelBag, withIdentifier: autoCancelTapIdentifier)
    }
}
