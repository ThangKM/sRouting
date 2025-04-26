//
//  AsyncActionTests.swift
//  sRouting
//
//  Created by Thang Kieu on 14/1/25.
//

@testable import sRouting
import Foundation
import Testing

@Suite("AsyncAction Tests")
struct AsyncActionTests {
    
    @Test
    func asyncAtion() async throws {
        let action = AsyncAction<Int, String> { value in
            String(value)
        }
        let result = try await action.asyncExecute(1)
        #expect(result == "1")
    }
    
    @Test
    func asyncActionInput() async throws {
        let action = AsyncActionPut<Int> { value in
            #expect(value == 1)
        }
        try await action.asyncExecute(1)
        
    }
    
    @Test
    func asynActionOutput() async throws {
        let action = AsyncActionGet {
            1
        }
        let result = try await action.asyncExecute()
        #expect(result == 1)
    }
    
    @Test
    func testAsyncActionVoidOutput() async throws {
        let waiter = Waiter()
        let asyncAction = AsyncAction<Int, Void> { input in
            #expect(input == 42)
            waiter.fulfill()
        }
        asyncAction.execute(42)
        try await waiter.waiting()
    }

    @Test
    func testAsyncActionVoidInputAndOutput() async throws {
        let waiter = Waiter()
        let asyncAction = AsyncAction<Void, Void> {
            waiter.fulfill()
        }
        asyncAction.execute()
        try await waiter.waiting()
    }

    @Test
    func testAsyncActionNotEqual() {
        let action1 = AsyncAction<Int, String> { _ in "Action1" }
        let action2 = AsyncAction<Int, String> { _ in "Action2" }
        let isEqual = action1 == action2
        #expect(isEqual == false)
    }
    
    @Test
    func testAsyncActionHashable() {
        let action1 = AsyncAction<Int, String> { _ in "Action1" }
        let action2 = action1
        let isEqual = action1 == action2
        #expect(isEqual)
    }
}
