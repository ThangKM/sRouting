//
//  AsyncAction.swift
//  sRouting
//
//  Created by Thang Kieu on 8/1/25.
//

import Foundation

public typealias AsyncActionVoid = AsyncAction<Void,Void>
public typealias AsyncActionGet<Output> = AsyncAction<Void,Output>
public typealias AsyncActionPut<Input> = AsyncAction<Input,Void>

public struct AsyncAction<Input,Output>: Sendable
where Input: Sendable, Output: Sendable {
    
    public typealias WorkAction = @Sendable (Input) async throws -> Output
    
    private let identifier = UUID().uuidString
    private let action: WorkAction
    
    public init (_ action: @escaping WorkAction) {
        self.action = action
    }
    
    @discardableResult
    public func execute(_ input: Input) async throws -> Output {
        try await action(input)
    }
}

extension AsyncAction where Input == Void {
    
    @discardableResult
    public func execute() async throws -> Output {
        try await action(Void())
    }
}

extension AsyncAction where Output == Void {
    
    public func executeInNewTask(_ input: Input) {
        Task {
            try await action(input)
        }
    }
}

extension AsyncAction: Hashable {
    
    public static func == (lhs: AsyncAction<Input, Output>, rhs: AsyncAction<Input, Output>) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
