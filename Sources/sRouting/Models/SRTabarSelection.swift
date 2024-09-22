//
//  SRTabbarSelection.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation

/// Tabbar's selection Observation
@Observable @MainActor
public final class SRTabbarSelection {
    
    typealias SignalChange = Bool
    
    public var selection: Int {
        get {
            access(keyPath: \.selection)
            return _selection
        }
        set {
            if newValue == _selection {
                tapCountStream.increase()
                _autoCancelTapCount()
            } else {
                tapCountStream.resetCount()
            }
            withMutation(keyPath: \.selection) {
                _selection = newValue
            }
        }
    }
    
    internal var doubleTapEmmiter: SignalChange = false
    
    @ObservationIgnored
    private var _selection: Int = .zero
    
    nonisolated private let tapCountStream = IncreaseCountStream()
    nonisolated private let cancelBag = CancelBag()
    nonisolated private let autoCancelTapIdentifier = "autoCancelTapIdentifier"
    
    public init() {
        _observeTapCountStream()
    }
    
    public func select(tag: Int) {
        selection = tag
    }
    
    private func _emmitDoubleTap() {
        doubleTapEmmiter = !doubleTapEmmiter
    }
    
    deinit { cancelBag.cancelAll() }
}

extension SRTabbarSelection {
    
    nonisolated private func _observeTapCountStream() {
        Task.detached {[weak self] in
            
            guard let stream = self?.tapCountStream.stream,
            let cancelTapId = self?.autoCancelTapIdentifier
            else { return }
            
            for await _ in stream.filter({ $0 == 2 }) {
                try Task.checkCancellation()
                await self?._emmitDoubleTap()
                self?.tapCountStream.resetCount()
                self?.cancelBag.cancel(forIdentifier: cancelTapId)
            }
        }.store(in: cancelBag)
    }

    nonisolated private func _autoCancelTapCount() {
        cancelBag.cancel(forIdentifier: autoCancelTapIdentifier)
        Task.detached {[weak self] in
            do {
                try await Task.sleep(for: .milliseconds(400))
                try Task.checkCancellation()
                self?.tapCountStream.resetCount()
                guard let cancelId = self?.autoCancelTapIdentifier else { return }
                self?.cancelBag.cancel(forIdentifier: cancelId)
            }
        }.store(in: cancelBag, withIdentifier: autoCancelTapIdentifier)
    }
}
