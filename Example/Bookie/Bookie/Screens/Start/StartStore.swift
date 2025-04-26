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
    
    enum StartAction: Sendable, ActionLockable {
        case startAction
    }
}

extension StartScreen {
    
    actor StartStore: ActionStore {
        
        private weak var router: SRRouter<AppAlertsRoute>?
        private weak var state: ScreenStates?
        
        private lazy var bookService: BookService = .init()
        private let actionLocker = ActionLocker()
        
        func binding(state: ScreenStates) {
            self.state = state
        }
        
        func binding(router: SRRouter<AppAlertsRoute>) {
            self.router = router
        }
        
        nonisolated func receive(action: StartAction) {
            Task {
                guard await actionLocker.canExecute(action) else { return }
                await state?.loadingStarted()
                do {
                    switch action {
                    case .startAction:
                       try await  _generateBooksIfNeeded()
                    }
                } catch {
                    
                }
                await state?.loadingFinished()
                await actionLocker.unlock(action)
            }
        }
    }
}


extension StartScreen.StartStore {
    
    func _generateBooksIfNeeded() async throws {
        guard await bookService.isDatabaseEmpty() else {
            await router?.switchTo(route: AppRoute.homeScreen)
            return
        }
        try await bookService.generateBooks(count: 55)
        await router?.switchTo(route: AppRoute.homeScreen)
    }
}

