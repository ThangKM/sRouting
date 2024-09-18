//
//  SRTabbarSelection.swift
//
//
//  Created by Thang Kieu on 31/03/2024.
//

import Foundation

/// Tabbar's selection Observation
@Observable
public final class SRTabbarSelection: Sendable {
    
    typealias SignalChange = Bool
    
    @MainActor
    public var selection: Int {
        get {
            access(keyPath: \.selection)
            return _selection
        }
        set {
            if newValue == _selection {
                
                tapCountStream.increase()
                _autoCancelTapCount()
                
                #if canImport(UIKit)
                _emitPopToRootIfNeeded()
                #endif
            } else {
                tapCountStream.resetCount()
            }
            withMutation(keyPath: \.selection) {
                _selection = newValue
            }
        }
    }
    
    @MainActor
    internal var doubleTapEmmiter: SignalChange = false
    
    @MainActor var popToRoot: SignalChange = false
    
    @ObservationIgnored @MainActor
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
        doubleTapEmmiter = !doubleTapEmmiter
    }
    
    #if canImport(UIKit)
    @MainActor
    private func _emitPopToRootIfNeeded() {
        guard #available(iOS 18.0, *) else { return }
        popToRoot = !popToRoot
    }
    #endif
    
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
