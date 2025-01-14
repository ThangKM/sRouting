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
        let result = try await action.execute(1)
        #expect(result == "1")
    }
    
    @Test
    func asyncActionInput() async throws {
        let action = AsyncActionPut<Int> { value in
            #expect(value == 1)
        }
        try await action.execute(1)
        
    }
    
    @Test
    func asynActionOutput() async throws {
        let action = AsyncActionGet {
            1
        }
        let result = try await action.execute()
        #expect(result == 1)
    }
}
