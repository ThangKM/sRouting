//
//  CoordinatorMacroTest.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Observation
@testable import sRouting

#if canImport(sRoutingMacros) && os(macOS)
import sRoutingMacros

final class CoordinatorMacroTest: XCTestCase {
    
    func testCoordinatorMacroImp() async throws {
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
        struct Coordinator { 
        
        }
        """, expandedSource: """
        struct Coordinator { 

            @MainActor let rootRouter = SRRouter(AnyRoute.self)

            @MainActor let dismissAllEmitter = SRDismissAllEmitter()

            @MainActor let tabSelection = SRTabbarSelection()

            @MainActor private let navStacks = [SRNavStack.home: SRNavigationPath(), SRNavStack.setting: SRNavigationPath()]

            @MainActor
            var homePath: SRNavigationPath {
                navStacks[SRNavStack.home]!
            }

            @MainActor
            var settingPath: SRNavigationPath {
                navStacks[SRNavStack.setting]!
            }

            @MainActor init() {
            }

            @MainActor
            private func navigationPath(of stackItem: SRNavStack) -> SRNavigationPath {
                navStacks[stackItem]!
            }

            @MainActor
            private func _routing(for route: SRRootRoute) async {
                switch route {
                case .resetAll:
                    dismissAllEmitter.dismissAll()
                    navStacks.values.forEach({
                        $0.popToRoot()
                    })
                case .dismissAll:
                    dismissAllEmitter.dismissAll()
                case .popToRoot(of: let stack):
                    navigationPath(of: stack).popToRoot()
                case .select(tabItem: let tabItem):
                    tabSelection.select(tag: tabItem.rawValue)
                case .push(route: let route, into: let stack):
                    let navigation = navigationPath(of: stack)
                    guard navigation.didAppear else {
                       do {
                        try await Task.sleep(for: .milliseconds(300))
                       } catch {
                        print("sRouting.\\(error)")
                       }
                       navigation.push(to: route)
                       try? await Task.sleep(for: .milliseconds(300))
                       return
                    }
                    navigation.push(to: route)
                    try? await Task.sleep(for: .milliseconds(300))
                case .sheet(let route):
                    rootRouter.trigger(to: AnyRoute(route: route), with: .sheet)
                case .window(let windowTrans):
                    rootRouter.openWindow(windowTrans: windowTrans)
                #if os(iOS)
                case .present(let route):
                    rootRouter.trigger(to: .init(route: route), with: .present)
                #endif
                }
            }

            @MainActor
            func routing(_ routes: SRRootRoute...) async {
                let routeStream = AsyncStream { continuation in
                    for route in routes {
                        continuation.yield(route)
                    }
                    continuation.finish()
                }

                for await route in routeStream {
                    await _routing(for: route)
                }
            }

        }

        extension Coordinator: sRouting.SRRouteCoordinatorType {
            enum SRRootRoute: SRRoute {
                case resetAll
                case dismissAll
                case popToRoot(of: SRNavStack)
                case select(tabItem: SRTabItem)
                case push(route: any SRRoute, into: SRNavStack)
                case sheet(any SRRoute)
                case window(SRWindowTransition)
                #if os(iOS)
                case present(any SRRoute)
                #endif

                var screen: some View {
                   fatalError("sRouting.SRRootRoute doesn't have screen")
                }

                var path: String {
                    switch self {
                    case .resetAll:
                        return "rootroute.resetall"
                    case .dismissAll:
                        return "rootroute.dismissall"
                    case .select:
                        return "rootroute.selecttab"
                    case .push(let route, _):
                        return "rootroute.push.\\(route.path)"
                    case .sheet(let route):
                        return "rootroute.sheet.\\(route.path)"
                    case .window(let transition):
                        if let id = transition.windowId {
                            return "rootroute.window.\\(id)"
                        } else if let value = transition.windowValue {
                            return "rootroute.window.\\(value.hashValue)"
                        } else {
                            return "rootroute.window"
                        }
                    case .popToRoot:
                        return "rootroute.popToRoot"
                    #if os(iOS)
                    case .present(let route):
                        return "rootroute.present.\\(route.path)"
                    #endif
                    }
                }
            }

            enum SRTabItem: Int, Sendable {
                case homeItem
                case settingItem
            }

            enum SRNavStack: String, Sendable {
                case home
                case setting
            }
        }
        """, macros:testMacros)
    }
    
    func testNoneStructOrClassImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.structOrClass.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
        enum Coordinator {
        }
        """, expandedSource:"""
        enum Coordinator {
        }
        """,
        diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
    
    func testMissingArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.missingArguments.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: [], stacks: "")
        struct Coordinator {
        }
        """, expandedSource:"""
        struct Coordinator {
        }
        """,
        diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
    
    func testTabItemDuplicationArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: ["home","home"], stacks: "home")
        struct Coordinator {
        }
        """, expandedSource:"""
        struct Coordinator {
        }
        """,
        diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
    
    func testStackDuplicationArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRouteCoordinator(tabs: ["home", "setting"], stacks: "home", "setting", "home")
        struct Coordinator {
        }
        """, expandedSource:"""
        struct Coordinator {
        }
        """,
        diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
}
#endif
