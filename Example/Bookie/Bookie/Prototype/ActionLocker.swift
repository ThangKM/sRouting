//
//  ActionLocker.swift
//  Bookie
//
//  Created by Thang Kieu on 27/4/25.
//

import Foundation

public protocol ActionLockable {
    var lockkey: String { get }
}

extension ActionLockable {
    public var lockkey: String {
        let name = String(describing: self).prefix(100)
        return String(name)
    }
}

public actor ActionLocker {
    
    private var actions: [String: Bool]
    
    public init() {
        actions = .init()
    }
    
    public func lock(_ action: ActionLockable) throws {
        let isRunning = actions[action.lockkey] ?? false
        guard !isRunning else {
            throw Errors.actionIsRunning
        }
        actions.updateValue(true, forKey: action.lockkey)
    }
    
    public func unlock(_ action: ActionLockable) {
        guard actions[action.lockkey] != .none else { return }
        actions.updateValue(false, forKey: action.lockkey)
    }
    
    public func canExecute(_ action: ActionLockable) -> Bool {
        do {
            try lock(action)
            return true
        } catch {
            return false
        }
    }
    
    public func free() {
        actions.removeAll()
    }
}

extension ActionLocker {
    
    public enum Errors: Error {
        case actionIsRunning
    }
}
