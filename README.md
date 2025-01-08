
# sRouting

[![Building Actions Status](https://github.com/ThangKM/sRouting/workflows/Building/badge.svg)](https://github.com/ThangKM/sRouting/actions)
![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS-blue?style=flat-square)
[![codecov.io](https://codecov.io/gh/ThangKM/sRouting/branch/main/graphs/badge.svg?branch=main)](https://codecov.io/github/ThangKM/sRouting?branch=main)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

The lightweight navigation framework for SwiftUI.

## Overview

sRouting using the native navigation mechanism in SwiftUI.
It's easy to handle navigation between screens by sRouting.

![A sRouting banner.](https://github.com/ThangKM/sRouting/blob/main/Sources/sRouting/DocsRouting.docc/Resources/sRouting/srouting_banner.png)

## Requirements

- iOS 17 or above
- Xcode 16 or above

## 📚 Documentation
Explore DocC to find rich tutorials and get started with sRouting.
See [this WWDC presentation](https://developer.apple.com/videos/play/wwdc2021/10166/) about more information.

From xCode select Product -> Build Doccumentation -> Explore.

## 🛠 Installation

Add `sRouting` as a dependency to the project.
See [this WWDC presentation](https://developer.apple.com/videos/play/wwdc2019/408/) for more information on how to adopt Swift packages in your app.
Specify `https://github.com/ThangKM/sRouting.git` as the `sRouting` package link.

![](https://github.com/ThangKM/sRouting/blob/main/Sources/sRouting/DocsRouting.docc/Resources/Bookie/SectionOne/bookie_add_srouting.png)

## 🏃‍♂️ Getting Started with sRouting

Set up `SRRootView` and work with `sRouter(_:)`

## Overview

Create your root view with ``SRRootView``.
Declares your ``SRRoute``.
Working with macros and ViewModifers.

### Create a Route

To create a route we have to conform to the ``SRRoute`` Protocol.

```swift
enum HomeRoute: SRRoute {
    case pastry
    case cake
    
    var path: String { 
        swich self {
            case .pastry: return "pastry"
            case .cake: return "cake"
        }
    }

    var screen: some View {
        switch self {
            case .pastry: PastryScreen()
            case .cake: CakeScreen()
        }
    }
}
```

### Make your Root View

Setup a coordinator and ``SRRootView`` for your app

Declaring a coordinator: 

```swift
@sRouteCoordinator(tabs: ["home", "setting"], stacks: "home", "setting")
struct AppCoordinator { }
```

Declaring View of navigation destination:

```swift
@sRouteObserver(HomeRoute.self, SettingRoute.self)
struct RouteObserver { }
```

Setup Your App:

```swift
@main
struct BookieApp: App { 
    let coordinator = AppCoordinator()
    ...
    var body: some Scene {

        WindowGroup {
            SRRootView(coordinator: coordinator) {
                @Bindable var tabSelection = coordinator.tabSelection
                TabView(selection: $tabSelection.selection) {
                    NavigationStack(path: coordinator.homePath) {
                        AppRoute.home.screen
                            .routeObserver(RouteObserver.self)
                    }.tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(SRTabItem.home.rawValue)
                    
                    NavigationStack(path: coordinator.settingPath) {
                        AppRoute.setting.screen
                            .routeObserver(RouteObserver.self)
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
                    await coordinator.routing(.resetAll,.select(tabItem: .home),
                                          .push(route: HomeRoute.cake, into: .home))
                }
            }
        }
    }
}
```
### Make a Screen and working with Router

Using the `onRouting(of:)` ViewModifier to observe router transition.

```swift
enum HomeRoute: SRRoute {
    case detail
    ...
}

struct HomeScreen: View {

    @State var homeRouter = SRRouter(HomeRoute.self)

    var body: some View {
        VStack { 
            ...
        }
        .onRouting(of: homeRouter)
    }
```

DeepLink:
```swift
...
.onOpenURL { url in
    Task {
        ...
        await coordinator.routing(.resetAll,.select(tabItem: .home),
                              .push(route: HomeRoute.cake, into: .home))
    }
}
```

Push:
```swift
router.trigger(to: .cake, with: .push)
```
NavigationLink:
```swift
NavigationLink(route: HomeRoute.pastry) {
   ...
}
```
Present full screen:
```swift
router.trigger(to: .cake, with: .present)
```
Sheet:
```swift
router.trigger(to: .cake, with: .sheet)
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

router.pop(to: HomeRoute.cake)
```

### Conclusion
sRouting is a lightweight framework and flexiable.

## 📃 License

`sRouting` is released under an MIT license. See [License.md](https://github.com/ThangKM/sRouting/blob/main/LICENSE) for more information.
