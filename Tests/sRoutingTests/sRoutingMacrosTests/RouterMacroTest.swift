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
import sRoutingMacros
import sRouting
import Observation
import SwiftUI

let testMacros: [String: Macro.Type] = [
    "Router": RouterMacro.self,
]

final class RouterMacroTest: XCTestCase {

    func testRouterMacroImp() throws {
        
        assertMacroExpansion("""
        @sRouter(HomeRoute.self) @Observalbe
        class HomeViewModel {
            
        }
        """, expandedSource:"""
        class HomeViewModel {
            @ObservationTracked
            private (set) var transition: SRTransition<HomeRoute> = .none {
                @storageRestrictions(initializes: _transition)
                init(initialValue) {
                    _transition  = initialValue
                }
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

            @ObservationIgnored
            private var _transition: SRTransition<HomeRoute> = .none

            /// Select tabbar item at index
            /// Required oberve selection of `TabView` from ``RootRouter``
            /// - Parameter index: Index of tabbar item
            ///
            /// ### Example
            /// ```swift
            /// router.selectTabbar(at: 0)
            /// ```
            open func selectTabbar(at index: Int) {
                transition = .init(selectTab: index)
            }

            /// Trigger to new screen
            /// - Parameters:
            ///   - route: Type of ``Route``
            ///   - action: ``SRTriggerType``
            ///
            /// ### Example
            /// ```swift
            /// router.trigger(to: .detailScreen, with: .push)
            /// ```
            open func trigger(to route: HomeRoute, with action: SRTriggerType) {
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
            open func show(error: Error, and title: String? = nil) {
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
            open func show(alert: Alert) {
                transition = .init(with: alert)
            }

            #if os(iOS) || os(tvOS)
            open func show(actionSheet: ActionSheet) {
                transition = .init(with: actionSheet)
            }
            #endif

            /// Dismiss or pop current screen
            ///
            /// ### Example
            /// ```swift
            /// router.dismiss()
            /// ```
            open func dismiss() {
                transition = .init(with: .dismiss)
            }

            /// Dismiss to root view
            ///
            /// ### Example
            /// ```swift
            /// router.dismissAll()
            /// ```
            open func dismissAll() {
                transition = .init(with: .dismissAll)
            }

            func resetTransition(scenePhase: ScenePhase) {
               guard scenePhase == .active else { return }
               transition = .none
            }
        
            @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()

            internal nonisolated func access<Member>(
                keyPath: KeyPath<HomeViewModel , Member>
            ) {
              _$observationRegistrar.access(self, keyPath: keyPath)
            }

            internal nonisolated func withMutation<Member, MutationResult>(
              keyPath: KeyPath<HomeViewModel , Member>,
              _ mutation: () throws -> MutationResult
            ) rethrows -> MutationResult {
              try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
            }
        }
        extension HomeViewModel: Observation.Observable {
        }
        extension HomeViewModel: sRouting.SRRouterType {
        }
        """,
        macros: testMacros)
    }
}
