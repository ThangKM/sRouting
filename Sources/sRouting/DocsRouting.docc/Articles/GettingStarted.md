# Getting Started with sRouting

Set up ``SRRootView`` and working with ``sRouter(_:)``

## Overview

Create your root view with ``SRRootView``.
Declares your ``SRRoute``.
Working with ``sRContext(tabs:stacks:)``, ``ScreenView`` and ``sRouter(_:)`` macro.

### Create a Route

To create a route we have to conform to the ``SRRoute`` Protocol.

```swift
enum AppRoute: SRRoute {
    case login
    case tabbar
    
    var path: String { 
        swich self {
            case .login: return "login"
            case .tabbar: return "tabbar"
        }
    }

    var screen: some View {
        switch self {
            case .login: LoginScreen()
            case .tabbar: TabbarScreen()
        }
    }
}
```

### Make your Root View

Setup a context and ``SRRootView`` for your app

```swift
@sRContext(tabs: ["home", "setting"], stacks: "home", "setting")
struct SRContext { }

@main
struct BookieApp: App { 
    let context = SRContext()
    ...
    var body: some Scene {

        WindowGroup {
            SRRootView(context: context) {
                SRTabbarView {
                    SRNavigationStack(path: context.homePath) {
                        AppRoute.home.screen
                    }.tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(SRTabItem.home.rawValue)
                    
                    SRNavigationStack(path: context.settingPath) {
                        AppRoute.setting.screen
                    }.tabItem {
                        Label("Setting", systemImage: "gear")
                    }.tag(SRTabItem.setting.rawValue)
                }
                .onDoubleTapTabItem { ... }
                .onTabSelectionChange { ... }
            }
            .onOpenURL { url in
                Task {
                    ...
                    await context.routing(.resetAll,.select(tabItem: .setting),
                                          .push(route: SettingRoute.detail, into: .setting))
                }
            }
        }
    }
}
```
### Make a Screen and working with Router

Build a screen with ``ScreenView``, ``ScreenView`` will create a hidden NavigatorView at below content view
in a ZStack.
The NavigatorView will handle transactions that are emited by `Router`

```swift
enum HomeRoute: SRRoute {
    case detail
    ...
}

@sRouter(HomeRoute.self)
class HomeViewModel { ... }

struct HomeScreen: View {

    @Environment(\.dismiss)
    private var dismissAction

    @State let viewModel = HomeViewModel()

    var body: some View {
        ScreenView(router: viewModel, dismissAction: dismissAction) {
        ...
        }
    }
```

To navigate to a screen that must be in HomeRoute 
we use the `trigger(to:with:)` function in the `Router`

Push:
```swift
router.trigger(to: .detail, with: .push)
```
NavigationLink:
```swift
NavigationLink(route: HomeRoute.detail("\(value)")) {
   ...
}
```
Present full screen:
```swift
router.trigger(to: .detail, with: .present)
```
Sheet:
```swift
router.trigger(to: .detail, with: .sheet)
```
To show an alert we use the `show(alert:)` function.

```swift
 router.show(alert:  Alert.init(title: Text("Alert"),
                                message: Text("Message"),
                                dismissButton: .cancel(Text("OK")))
```

To show an error message we use the `show(error:and:)` function.

```swift
router.show(error:NetworkingError.lossConnection)
```

To dismiss a screen we use the `dismiss()` function.

```swift
router.dismiss()
```

To dismiss to root view we use the `dismissAll()` function.
Required the root view is a ``SRRootView``

```swift
router.dismissAll()
```
To seclect the Tabbar item we use the `selectTabbar(at:)` function.

```swift
router.selectTabbar(at:0)
```

sRouting also supported pop, pop to root and pop to a target function for the NavigationView

```swift
router.pop()

router.popToRoot()

router.pop(to: HomeRoute.detail)
```
