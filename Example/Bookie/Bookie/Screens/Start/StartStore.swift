//
//  StartStore.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import sRouting
import Foundation
import SwiftData

extension StartScreen {
    
    @Observable @MainActor
    final class StartState {
        
        private(set) var isLoading: Bool = false
        
        func updateLoading(_ loading: Bool) {
            isLoading = loading
        }
    }
    
    enum StartAction: Sendable {
        case startAction
    }
}


extension StartScreen {
    
    final class StartStore: ActionStore {
        
        private let showHomeAction: AsyncActionPut<Bool>
        private weak var router: SRRouter<AppAlertsRoute>?
        private weak var state: StartState?
        
        private lazy var bookService: BookService = .init()
        
        init(showHomeAction: AsyncActionPut<Bool>) {
            self.showHomeAction = showHomeAction
        }
        
        func binding(state: StartState, router: SRRouter<AppAlertsRoute>) {
            self.router = router
            self.state = state
        }
        
        func receive(action: StartAction) {
            assert(EnvironmentRunner.current == .livePreview || (state != nil && router != nil), "Missing binding state, router or running on live preview")
            switch action {
            case .startAction:
                _synchronizeBookIfNeeded()
            }
        }
    }
}


extension StartScreen.StartStore {
    
    func _synchronizeBookIfNeeded() {
        Task {
            state?.updateLoading(true)
            do {
                guard await bookService.isDatabaseEmpty() else {
                    try await showHomeAction.execute(true)
                    return
                }
                try await bookService.synchronizeBooksFromMockData()
                try await showHomeAction.execute(true)
            } catch {
                router?.show(alert: .failedSyncBooks)
            }
            state?.updateLoading(false)
        }
    }
}
