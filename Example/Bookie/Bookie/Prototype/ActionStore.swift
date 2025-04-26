//
//  ActionStore.swift
//  Bookie
//
//  Created by Thang Kieu on 16/1/25.
//

import SwiftUI
import sRouting

//MARK: - Base Screen States
@Observable @MainActor
open class ScreenStates {
    
    private weak var parentState: ScreenStates?
    
    public var isLoading: Bool = false {
        didSet {
            parentState?.loadingStarted()
        }
    }
    
    public var displayError: DisplayableError? {
        didSet {
            parentState?.showError(displayError)
            if displayError != nil {
                isLoading = false
            } else {
                updateStateLoading()
            }
        }
    }
    
    @ObservationIgnored
    private var loadingTaskCount: Int = 0 {
        didSet {
            updateStateLoading()
        }
    }
    
    nonisolated
    public let cancelBag = CancelBag()
    
    public init() { }

    public init(states: ScreenStates) {
        self.parentState = states
    }
    
    deinit {
        cancelBag.cancelAllInTask()
    }
}

//MARK: - Updaters
extension ScreenStates {
    
    private func updateStateLoading() {
        let loading = loadingTaskCount > 0
        if loading != self.isLoading {
            withAnimation {
                isLoading = loading
            }
        }
    }
    
    public func showError(_ error: LocalizedError?) {
        guard let error else {
            self.displayError = .none
            return
        }
        withAnimation {
            self.displayError = .init(message: error.localizedDescription)
        }
    }
    
    public func loadingStarted() {
        loadingTaskCount += 1
    }
    
    public func loadingFinished() {
        guard loadingTaskCount > 0 else { return }
        loadingTaskCount -= 1
    }
    
    public func loadingStarted(action: LoadingTrackable) {
        guard action.canTrackLoading else { return }
        loadingStarted()
    }
    
    public func loadingFinished(action: LoadingTrackable) {
        guard action.canTrackLoading else { return }
        loadingFinished()
    }
}

//MARK: - Action Store
protocol ActionStore: Actor {
    
    associatedtype ScreenState: ScreenStates
    associatedtype Action: Sendable & ActionLockable
    
    func binding(state: ScreenState)
    nonisolated func receive(action: Action)
}
