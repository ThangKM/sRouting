//
//  RouterModifierTests.swift
//
//
//  Created by ThangKieu on 7/8/21.
//

import SwiftUI
import ViewInspector
import Testing
@testable import sRouting

@Suite("Test RouterModifer")
@MainActor
struct RouterModifierTests {
    
    let router = SRRouter(TestRoute.self)
    let coordinator = Coordinator()
    let context = SRContext()

    @Test
    func testActiveAlert() async throws {
        var isActive = false
        let waiter = Waiter()
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveAlert
            waiter.fulfill()
        }))
        
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.show(alert: .timeOut)
        try await waiter.waiting()
        #expect(isActive)
    }
    
    @Test
    func testDismissAll() async throws {
        var isActive = true
        let waiter = Waiter()
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveAlert && view.isActiveSheet && view.isActivePresent && view.isActiveDialog
            waiter.fulfill()
        }))
        
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.dismissAll()
        try await waiter.waiting()
        #expect(!isActive)
    }
    
    @Test
    func testDismissCoordinator() async throws {
        var isEnter = false
        let waiter = Waiter()
        let sut = SRRootView(context: context, coordinator: coordinator) {
            TestScreen(router: router, tests: nil)
                .onChange(of: coordinator.emitter.dismissEmiiter) { oldValue, newValue in
                    isEnter = true
                    waiter.fulfill()
                }
        }
        
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.dismissCoordinator()
        try await waiter.waiting()
        #expect(isEnter)
    }
    
    @Test
    func testPush() async throws {
        var pathCount = 0
        let waiter = Waiter()
        let sut = NavigationStack(path: coordinator.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                pathCount = newPaths.count
                waiter.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.trigger(to: .emptyScreen, with: .push)
        try await waiter.waiting()
        #expect(pathCount == 1)
    }
    
    @Test
    func testPop() async throws {
        var pathCount = 1
        let waiter = Waiter()
        let sut = NavigationStack(path: coordinator.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                pathCount = newPaths.count
                if newPaths.isEmpty {
                    waiter.fulfill()
                }
            }
        }
        ViewHosting.host(view: sut)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.pop()
        try await waiter.waiting()
        #expect(pathCount == .zero)
    }
    
    @Test
    func testPopToRoot() async throws {
        var pathCount = 1
        let sut = NavigationStack(path: coordinator.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                pathCount = newPaths.count
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .home, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .setting, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.popToRoot()
        try await Task.sleep(for: .milliseconds(10))
        #expect(pathCount == .zero)
    }
    
    @Test
    func testPopToTarget() async throws {
        var paths = [String]()
        
        let sut = NavigationStack(path: coordinator.testStackPath) {
            TestScreen(router: router, tests: .none).onNaviStackChange { oldPaths, newPaths in
                paths = newPaths
            }
        }
        ViewHosting.host(view: sut)
        router.trigger(to: .home, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .emptyScreen, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.trigger(to: .setting, with: .push)
        try await Task.sleep(for:.milliseconds(50))
        router.pop(to: TestRoute.Paths.home)
        let path = try #require(paths.first)
        try await Task.sleep(for: .milliseconds(10))
        #expect(paths.count == 1)
        #expect(path.contains(TestRoute.Paths.home.rawValue))
    }
    
//    @Test
//    func testOnDoubleTap() async throws {
//        let waiter = Waiter()
//        let selection = ValueBox(value: -1)
//        let tabManager = SRTabbarSelection()
//        let sut = Text("Testing")
//                    .onDoubleTapTabItem { value in
//                        selection.update(with: value)
//                        waiter.fulfill()
//                    }
//                    .environment(tabManager)
//        ViewHosting.host(view: sut)
//        try await Task.sleep(for:.milliseconds(50))
//        tabManager.select(tag: 0)
//        try await Task.sleep(for:.milliseconds(100))
//        tabManager.select(tag: 0)
//        try await waiter.waiting()
//        #expect(selection.value == .zero)
//    }
    
    @Test
    func testActiveSheet() async throws {
        var isActive = false
        let waiter = Waiter()
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveSheet
            waiter.fulfill()
        }))
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.trigger(to: .emptyScreen, with: .sheet)
        try await waiter.waiting()
        #expect(isActive)
    }
    
    @Test
    func testActiveConfirmationDialog() async throws {
        #if os(iOS)
        guard UIDevice.current.userInterfaceIdiom != .pad else { return }
        #endif
        let waiter = Waiter()
        let box = ValueBox(value: false)
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            box.update(with: view.isActiveDialog)
            waiter.fulfill()
        }))
        
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(50))
        router.show(dialog: .confirmOK)
        try await waiter.waiting()
        #expect(box.value)
    }
    
    @Test
    func testResetRouterTransitionByDialog() async throws {
        #if os(iOS)
        guard UIDevice.current.userInterfaceIdiom != .pad else { return }
        #endif
        var action: ActionBox?
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            action = .init(action: {
                view.resetActiveState()
            })
        }))
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.show(dialog: .confirmOK)
        try await Task.sleep(for: .milliseconds(10))
        action?.execute()
        try await Task.sleep(for: .milliseconds(10))
        #expect(router.transition == .none)
    }
    
    @Test
    func testResetRouterTransitionByAlert() async throws {
        var action: ActionBox?
        
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            action = .init(action: {
                view.resetActiveState()
            })
        }))
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.show(alert: .timeOut)
        try await Task.sleep(for: .milliseconds(10))
        action?.execute()
        try await Task.sleep(for: .milliseconds(10))
        #expect(router.transition == .none)
    }
    
    @Test
    func testResetRouterTransitionBySheet() async throws {
        var action: ActionBox?
        
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            action = .init(action: {
                view.resetActiveState()
            })
        }))
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.trigger(to: .home, with: .sheet)
        try await Task.sleep(for: .milliseconds(10))
        action?.execute()
        try await Task.sleep(for: .milliseconds(10))
        #expect(router.transition == .none)
    }
    
    #if os(macOS)
    @Test
    func testRouterActivePopover_Pad() async throws {
        var isActive = false
        let sut = PopoverScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActivePopover
        }))
        
        ViewHosting.host(view: sut)
        router.show(popover: .testPopover)
        try await Task.sleep(for: .milliseconds(50))
        #expect(isActive)
    }
    
    @Test
    func testResetRouterTransitionByPopover_Pad() async throws {
        var action: ActionBox?
        let waiter = Waiter()
        let sut = PopoverScreen(router: router, tests: .init(didChangeTransition: { view in
            action = .init(action: {
                view.resetActiveState()
                waiter.fulfill()
            })
        }))
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.show(popover: .testPopover)
        try await Task.sleep(for: .milliseconds(20))
        action?.execute()
        try await Task.sleep(for: .milliseconds(50))
        #expect(router.transition == .none)
    }
    #endif

    #if os(iOS)
    @Test
    func testActivePopover_Phone() async throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        let waiter = Waiter()
        let box = ValueBox(value: false)
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            box.update(with: view.isActivePopover)
            waiter.fulfill()
        }))
        
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .microseconds(50))
        router.show(popover: .testPopover)
        try await waiter.waiting()
        #expect(box.value)
    }
    
    @Test
    func testResetRouterTransitionByPopover_Phone() async throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        var action: ActionBox?
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            action = .init(action: {
                view.resetActiveState()
            })
        }))
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.show(popover: .testPopover)
        try await Task.sleep(for: .milliseconds(10))
        action?.execute()
        try await Task.sleep(for: .milliseconds(10))
        #expect(router.transition == .none)
    }
    
    @Test
    func testRouterActivePopover_Pad() async throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        var isActive = false
        let sut = PopoverScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActivePopover
        }))
        
        ViewHosting.host(view: sut)
        router.show(popover: .testPopover)
        try await Task.sleep(for: .milliseconds(50))
        #expect(isActive)
    }
    
    @Test
    func testResetRouterTransitionByPopover_Pad() async throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        var action: ActionBox?
        let waiter = Waiter()
        let sut = PopoverScreen(router: router, tests: .init(didChangeTransition: { view in
            action = .init(action: {
                view.resetActiveState()
                waiter.fulfill()
            })
        }))
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.show(popover: .testPopover)
        try await Task.sleep(for: .milliseconds(20))
        action?.execute()
        try await Task.sleep(for: .milliseconds(50))
        #expect(router.transition == .none)
    }
    
    @Test
    func testOnDialogRouterActiveConfirmationDialog() async throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        var isActive = false
        let sut = DialogScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActiveDialog
        }))
        
        ViewHosting.host(view: sut)
        router.show(dialog: .confirmOK)
        try await Task.sleep(for: .milliseconds(50))
        #expect(isActive)
    }
    
    @Test
    func testOnDialogRouterResetRouterTransitionByDialog() async throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        var action: ActionBox?
        let waiter = Waiter()
        let sut = DialogScreen(router: router, tests: .init(didChangeTransition: { view in
            action = .init(action: {
                view.resetActiveState()
                waiter.fulfill()
            })
        }))
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.show(dialog: .confirmOK)
        try await Task.sleep(for: .milliseconds(20))
        action?.execute()
        try await Task.sleep(for: .milliseconds(50))
        #expect(router.transition == .none)
    }
    
    @Test
    func testResetRouterTransitionByPresent() async throws {
        var action: ActionBox?
        
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            action = .init(action: {
                view.resetActiveState()
            })
        }))
        ViewHosting.host(view: sut)
        try await Task.sleep(for: .milliseconds(10))
        router.trigger(to: .home, with: .present)
        try await Task.sleep(for: .milliseconds(10))
        action?.execute()
        try await Task.sleep(for: .milliseconds(10))
        #expect(router.transition == .none)
    }
    
    @Test
    func testActivePresent() async throws {
        var isActive = false
        let sut = TestScreen(router: router, tests: .init(didChangeTransition: { view in
            isActive = view.isActivePresent
        }))
        
        ViewHosting.host(view: sut)
        router.trigger(to: .home, with: .present)
        try await Task.sleep(for: .milliseconds(10))
        #expect(isActive)
    }
    
    #endif
}

fileprivate final class ActionBox {
    
    let action : () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    func execute() {
        action()
    }
}

fileprivate final class ValueBox<T> {
    
    private(set) var value : T
    init(value: T) {
        self.value = value
    }
    
    func update(with value: T) {
        self.value = value
    }
}
