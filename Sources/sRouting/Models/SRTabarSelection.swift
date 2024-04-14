//
//  SRTabbarSelection.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation

/// Tabbar's selection Observation
@Observable
public final class SRTabbarSelection {
    
    @MainActor
    internal var selection: Int {
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
    
    internal var doubleTapEmmiter: Int = .zero
    
    @ObservationIgnored
    private var _selection: Int = .zero
    
    private let tapCountStream = IncreaseCountStream()
    private let cancelBag = CancelBag()
    
    public init() {
        _observeTapCountStream()
    }
    
    @MainActor
    public func select(tag: Int) {
        selection = tag
    }
}

extension SRTabbarSelection {
    
    private func _observeTapCountStream() {
        Task {
            for await _ in tapCountStream.stream.filter({ $0 == 2 }) {
                await _emmitDoubleTap()
                tapCountStream.resetCount()
                cancelBag.cancelAll()
            }
        }
    }
    
    @MainActor
    private func _emmitDoubleTap() {
        doubleTapEmmiter = if doubleTapEmmiter == .zero { 1 } else { .zero }
    }
    
    private func _autoCancelTapCount() {
        cancelBag.cancelAll()
        Task {
            do {
                try await Task.sleep(for: .milliseconds(400))
                try Task.checkCancellation()
                tapCountStream.resetCount()
            }
        }.store(in: cancelBag)
    }
}
