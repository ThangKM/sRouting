//
//  CoordinatorEmitterTests.swift
//  sRouting
//

import Testing
@testable import sRouting

@Suite("Test SRCoordinatorEmitter double tap")
@MainActor
struct CoordinatorEmitterTests {

    @Test
    func testReselectTwiceQuicklyEmitsDoubleTap() async throws {
        let emitter = SRCoordinatorEmitter()
        let initial = emitter.doubleTapTabItemEmmiter
        emitter.select(tag: 0)
        emitter.select(tag: 0)
        try await Task.sleep(for: .milliseconds(50))
        #expect(emitter.doubleTapTabItemEmmiter != initial)
    }

    @Test
    func testSingleReselectDoesNotEmit() async throws {
        let emitter = SRCoordinatorEmitter()
        let initial = emitter.doubleTapTabItemEmmiter
        emitter.select(tag: 0)
        try await Task.sleep(for: .milliseconds(50))
        #expect(emitter.doubleTapTabItemEmmiter == initial)
    }

    @Test
    func testSlowReselectDoesNotEmit() async throws {
        let emitter = SRCoordinatorEmitter()
        let initial = emitter.doubleTapTabItemEmmiter
        emitter.select(tag: 0)
        try await Task.sleep(for: .milliseconds(500))
        emitter.select(tag: 0)
        try await Task.sleep(for: .milliseconds(50))
        #expect(emitter.doubleTapTabItemEmmiter == initial)
    }

    @Test
    func testSwitchingTabResetsTapCount() async throws {
        let emitter = SRCoordinatorEmitter()
        let initial = emitter.doubleTapTabItemEmmiter
        emitter.select(tag: 0)
        emitter.select(tag: 1)
        emitter.select(tag: 1)
        try await Task.sleep(for: .milliseconds(50))
        #expect(emitter.doubleTapTabItemEmmiter == initial)
        #expect(emitter.tabSelection == 1)
    }
}
