//
//  ContextMacroTest.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import sRouting
import Observation


#if canImport(sRoutingMacros) && os(macOS)
import sRoutingMacros

final class ContextMacroTest: XCTestCase {
    
    func testContextMacroImp() async throws {
        assertMacroExpansion("""
        @sRContext(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
        struct SRContext {
        }
        """, expandedSource:"""
        struct SRContext {

            let rootRouter = SRRootRouter()

            let dismissAllEmitter = SRDismissAllEmitter()

            let tabSelection = SRTabbarSelection()

            private let navStacks = [SRNavStack.home: SRNavigationPath(), SRNavStack.setting: SRNavigationPath()]

            @MainActor
            var homePath: SRNavigationPath {
                navStacks[SRNavStack.home]!
            }

            @MainActor
            var settingPath: SRNavigationPath {
                navStacks[SRNavStack.setting]!
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
                        try await Task.sleep(for: .milliseconds(200))
                       } catch {
                        print("sRouting.\\(error)")
                       }
                       navigation.push(to: route)
                       return
                    }
                    navigation.push(to: route)
                case .sheet(let route):
                    rootRouter.trigger(to: AnyRoute(route: route), with: .sheet)
                case .window(let windowTrans):
                    rootRouter.openWindow(windowTrans: windowTrans)
                case .open(let url):
                    rootRouter.openURL(at: url, completion: nil)
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
        }@Observable
        final class SRRootRouter {

            @ObservationIgnored
            private var _transition: SRTransition<AnyRoute> = .none
        
            private(set) var transition: SRTransition<AnyRoute> {
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

            /// Select tabbar item at index
            /// - Parameter index: Index of tabbar item
            ///
            /// ### Example
            /// ```swift
            /// router.selectTabbar(at: 0)
            /// ```
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
            func trigger(to route: AnyRoute, with action: SRTriggerType) {
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
            func show(alert: Alert) {
                transition = .init(with: alert)
            }

            #if os(iOS) || os(tvOS)
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
            func dismiss() {
                transition = .init(with: .dismiss)
            }

            /// Dismiss to root view
            ///
            /// ### Example
            /// ```swift
            /// router.dismissAll()
            /// ```
            func dismissAll() {
                transition = .init(with: .dismissAll)
            }

            func pop() {
                transition = .init(with: .pop)
            }

            func popToRoot() {
                transition = .init(with: .popToRoot)
            }

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
            func openWindow(windowTrans: SRWindowTransition) {
                transition = .init(with: .openWindow, windowTransition: windowTrans)
            }

            /// Opens a URL, following system conventions.
            /// - Parameters:
            ///   - url: `URL`
            ///   - completion: `AcceptionCallback`
            func openURL(at url: URL, completion: AcceptionCallback?) {
                transition = .init(with: .openURL, windowTransition: .init(url: url, acceoption: completion))
            }

            #if os(macOS)
            /// Opens the document at the specified file URL.
            /// - Parameters:
            ///   - url: file URL
            ///   - completion: `ErrorHandler`
            func openDocument(at url: URL, completion: ErrorHandler?) {
                transition = .init(with: .openDocument, windowTransition: .init(url: url, errorHandler: completion))
            }
            #endif

        }

        enum SRRootRoute: SRRoute {
            case resetAll
            case dismissAll
            case popToRoot(of: SRNavStack)
            case select(tabItem: SRTabItem)
            case push(route: any SRRoute, into: SRNavStack)
            case sheet(any SRRoute)
            case window(SRWindowTransition)
            case open(url: URL)
            #if os(iOS)
            case present(any SRRoute)
            #endif

            var screen: some View {
               fatalError("sRouting.SRContextRoute doesn't have screen")
            }

            var path: String {
                switch self {
                case .resetAll:
                    return "srcontext.resetall"
                case .dismissAll:
                    return "srcontext.dismissall"
                case .select:
                    return "srcontext.selecttab"
                case .push(let route, _):
                    return "srcontext.push.\\(route.path)"
                case .sheet(let route):
                    return "srcontext.sheet.\\(route.path)"
                case .window(let transition):
                    if let id = transition.windowId {
                        return "srcontext.window.\\(id)"
                    } else if let value = transition.windowValue {
                        return "srcontext.window.\\(value.hashValue)"
                    } else {
                        return "srcontext.window"
                    }
                case .open(let url):
                    return "srcontext.openurl.\\(url.absoluteString)"
                case .popToRoot:
                    return "srcontext.popToRoot"
                #if os(iOS)
                case .present(let route):
                    return "srcontext.present.\\(route.path)"
                #endif
                }
            }
        }

        enum SRTabItem: Int {
            case homeItem
            case settingItem
        }

        enum SRNavStack: String {
            case home
            case setting
        }

        extension SRRootRouter: sRouting.SRRouterType {
        }

        extension SRContext: sRouting.SRContextType {
        }
        """,
        macros: testMacros)
    }
    
    func testNoneStructOrClassImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.structOrClass.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRContext(tabs: ["homeItem", "settingItem"], stacks: "home", "setting")
        enum SRContext {
        }
        """, expandedSource:"""
        enum SRContext {
        }

        extension SRContext: sRouting.SRContextType {
        }
        """,
                             diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
    
    func testMissingArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.missingArguments.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRContext(tabs: [], stacks: "")
        struct SRContext {
        }
        """, expandedSource:"""
        struct SRContext {
        }

        extension SRContext: sRouting.SRContextType {
        }
        """,
                             diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
    
    func testTabItemDuplicationArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRContext(tabs: ["home","home"], stacks: "home")
        struct SRContext {
        }
        """, expandedSource:"""
        struct SRContext {
        }

        extension SRContext: sRouting.SRContextType {
        }
        """,
                             diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
    
    func testStackDuplicationArgsImp() async throws {
        
        let dianosSpec = DiagnosticSpec(message: SRMacroError.duplication.description, line: 1, column: 1,severity: .error)
        
        assertMacroExpansion("""
        @sRContext(tabs: ["home", "setting"], stacks: "home", "setting", "home")
        struct SRContext {
        }
        """, expandedSource:"""
        struct SRContext {
        }

        extension SRContext: sRouting.SRContextType {
        }
        """,
                             diagnostics: [dianosSpec, dianosSpec],
        macros: testMacros)
    }
}
#endif
