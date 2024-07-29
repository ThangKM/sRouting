
# sRouting

[![Building Actions Status](https://github.com/ThangKM/sRouting/workflows/Building/badge.svg)](https://github.com/ThangKM/sRouting/actions)
![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS-blue?style=flat-square)
[![codecov.io](https://codecov.io/gh/ThangKM/sRouting/branch/main/graphs/badge.svg?branch=main)](https://codecov.io/github/ThangKM/sRouting?branch=main)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

The lightweight navigation framework for SwiftUI.

## Overview

sRouting using the native navigation mechanism in SwiftUI.
It's easy to handle navigation between screens by sRouting.
The ``Router`` can trigger a transition from inside(view) or outside(view model) the view.

![A sRouting banner.](https://github.com/ThangKM/sRouting/blob/main/Sources/sRouting/DocsRouting.docc/Resources/sRouting/srouting_banner.png)

## Requirements

- iOS 17 or above
- Xcode 15 or above

## 📚 Documentation
Explore DocC to find the rich tutorials and getting started with sRouting.
See [this WWDC presentation](https://developer.apple.com/videos/play/wwdc2021/10166/) about more information.

From xCode select Product -> Build Doccumentation -> Explore.

Or downloads the doccument archive from [release](https://github.com/ThangKM/sRouting/releases) 
## 🛠 Installation

Add `sRouting` as a dependency to the project.
See [this WWDC presentation](https://developer.apple.com/videos/play/wwdc2019/408/) about more information how to adopt Swift packages in your app.
Specify `https://github.com/ThangKM/sRouting.git` as the `sRouting` package link.

![](https://github.com/ThangKM/sRouting/blob/main/Sources/sRouting/DocsRouting.docc/Resources/Bookie/SectionOne/bookie_add_srouting.png)

## 🏃‍♂️ Getting Started with sRouting

Set up `SRRootView` and working with `sRouter(_:)`

## Overview

Create your root view with ``SRRootView``.
Declares your ``SRRoute``.
Working with ``sRContext(tabs:stacks:)`` macro, ``ScreenView`` and ``sRouter(_:)`` macro.

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

### Conclusion
sRouting is a lightweight framework and flexiable.

## 📃 License

`sRouting` is released under an MIT license. See [License.md](https://github.com/ThangKM/sRouting/blob/main/LICENSE) for more information.
