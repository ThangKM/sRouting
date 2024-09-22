//
//  RouterMacroTest.swift
//
//
//  Created by Thang Kieu on 18/03/2024.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import sRouting

///Using for dev
#if canImport(sRoutingMacros) && os(macOS)

import sRoutingMacros



final class RouterMacroTest: XCTestCase {

    func testRouterMacroImp() async throws {
        
        assertMacroExpansion("""
        @sRouter(HomeRoute.self) @Observable
        class HomeViewModel {
        }
        """, expandedSource:"""
        @Observable
        class HomeViewModel {

            @ObservationIgnored @MainActor
            private var _transition: SRTransition<HomeRoute> = .none

            @MainActor
            private(set) var transition: SRTransition<HomeRoute> {
                get {
                  access(keyPath: \\.transition)
                  return _transition
                }
                set {
                  withMutation(keyPath: \\.transition) {
                    _transition  = newValue
                  }
                }
            }

            @MainActor init() { }

            /// Select tabbar item at index
            /// - Parameter index: Index of tabbar item
            ///
            /// ### Example
            /// ```swift
            /// router.selectTabbar(at: 0)
            /// ```
            @MainActor
            func selectTabbar(at index: Int) {
                transition = .init(selectTab: index)
            }

            /// Trigger to new screen
            /// - Parameters:
            ///   - route: Type of ``SRRoute``
            ///   - action: ``SRTriggerType``
            ///
            /// ### Example
            /// ```swift
            /// router.trigger(to: .detailScreen, with: .push)
            /// ```
            @MainActor
            func trigger(to route: HomeRoute, with action: SRTriggerType) {
                transition = .init(with: route, and: .init(with: action))
            }

            /// Show an alert
            /// - Parameters:
            ///   - error: Type of `Error`
            ///   - title: The error's title
            ///
            /// ### Example
            /// ```swift
            /// router.show(NetworkingError.notFound)
            /// ```
            @MainActor
            func show(error: Error, and title: String? = nil) {
                transition = .init(with: error, and: title)
            }

            /// Show an alert
            /// - Parameter alert: Alert
            ///
            /// ### Example
            /// ```swift
            /// router.show(alert:  Alert.init(title: Text("Alert"),
            ///                                message: Text("Message"),
            ///                                dismissButton: .cancel(Text("OK")))
            /// ```
            @MainActor
            func show(alert: Alert) {
                transition = .init(with: alert)
            }

            #if os(iOS) || os(tvOS)
            @MainActor
            func show(actionSheet: ActionSheet) {
                transition = .init(with: actionSheet)
            }
            #endif

            /// Dismiss or pop current screen
            ///
            /// ### Example
            /// ```swift
            /// router.dismiss()
            /// ```
            @MainActor
            func dismiss() {
                transition = .init(with: .dismiss)
            }

            /// Dismiss to root view
            ///
            /// ### Example
            /// ```swift
            /// router.dismissAll()
            /// ```
            @MainActor
            func dismissAll() {
                transition = .init(with: .dismissAll)
            }

            @MainActor
            func pop() {
                transition = .init(with: .pop)
            }

            @MainActor
            func popToRoot() {
                transition = .init(with: .popToRoot)
            }

            @MainActor
            func pop(to route: some SRRoute) {
                transition = .init(popTo: route)
            }

            /// Opens a window that's associated with the specified transition.
            /// - Parameter windowTrans: ``SRWindowTransition``
            ///
            /// ### Example
            /// ```swif
            /// openWindow(windowTrans: windowTrans)
            /// ```
            @MainActor
            func openWindow(windowTrans: SRWindowTransition) {
                transition = .init(with: .openWindow, windowTransition: windowTrans)
            }

            /// Opens a URL, following system conventions.
            /// - Parameters:
            ///   - url: `URL`
            ///   - completion: `AcceptionCallback`
            @MainActor
            func openURL(at url: URL, completion: AcceptionCallback?) {
                transition = .init(with: .openURL, windowTransition: .init(url: url, acceoption: completion))
            }

            #if os(macOS)
            /// Opens the document at the specified file URL.
            /// - Parameters:
            ///   - url: file URL
            ///   - completion: `ErrorHandler`
            @MainActor
            func openDocument(at url: URL, completion: ErrorHandler?) {
                transition = .init(with: .openDocument, windowTransition: .init(url: url, errorHandler: completion))
            }
            #endif
        }

        extension HomeViewModel: sRouting.SRRouterType {
        }
        """,
        macros: testMacros)
    }
    
    func testNoneClassImp() async throws {
        assertMacroExpansion("""
        @sRouter(HomeRoute.self) @Observable
        struct HomeViewModel {
        }
        """, expandedSource: """
        @Observable
        struct HomeViewModel {
        }

        extension HomeViewModel: sRouting.SRRouterType {
        }
        """, diagnostics: [.init(message:SRMacroError.onlyClass.description,line: 1,column: 1,severity: .error)],
            macros: testMacros)
    }
    
    func testMissingArgs() async throws {
        assertMacroExpansion("""
        @sRouter() @Observable
        class HomeViewModel {
        }
        """, expandedSource: """
        @Observable
        class HomeViewModel {
        }

        extension HomeViewModel: sRouting.SRRouterType {
        }
        """, diagnostics: [.init(message:SRMacroError.missingArguments.description,line: 1,column: 1,severity: .error)],
            macros: testMacros)
    }
    
    func testInvalidArgs() async throws {
        assertMacroExpansion("""
        @sRouter("string") @Observable
        class HomeViewModel {
        }
        """, expandedSource: """
        @Observable
        class HomeViewModel {
        }

        extension HomeViewModel: sRouting.SRRouterType {
        }
        """, diagnostics: [.init(message:SRMacroError.invalidRouteType.description,line: 1,column: 1,severity: .error)],
            macros: testMacros)
    }
    
    func testMissingObservation() async throws {
        assertMacroExpansion("""
        @sRouter(HomeRoute.self)
        class HomeViewModel {
        }
        """, expandedSource: """
        class HomeViewModel {
        }

        extension HomeViewModel: sRouting.SRRouterType {
        }
        """, diagnostics: [.init(message:SRMacroError.missingObservable.description,line: 1,column: 1,severity: .error)],
            macros: testMacros)
    }
}

#endif
