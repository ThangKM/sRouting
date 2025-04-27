
# sRouting

[![Building Actions Status](https://github.com/ThangKM/sRouting/workflows/Building/badge.svg)](https://github.com/ThangKM/sRouting/actions)
![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS-blue?style=flat-square)
[![codecov.io](https://codecov.io/gh/ThangKM/sRouting/branch/main/graphs/badge.svg?branch=main)](https://codecov.io/github/ThangKM/sRouting?branch=main)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

The navigation framework for SwiftUI.

## Overview

sRouting provides a native navigation mechanism that simplifies handling navigation between screens.

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

## 🌀 Example: 
Explore the example brach: [Example](https://github.com/ThangKM/sRouting/tree/example)

## 🏃‍♂️ Getting Started with sRouting

Set up the `SRRootView` and interact with macros.

## Overview

Create your root view using `SRRootView`.
Declare your `SRRoute`.
Learn about macros and ViewModifers.

### Create a Route

To create a route, we must adhere to the `SRRoute` Protocol.

```swift
@sRoute
enum HomeRoute {

    typealias AlertRoute = YourAlertRoute // Optional declarations
    typealias ConfirmationDialogRoute = YourConfirmationDialogRoute // Optional declarations
    typealias PopoverRoute = YourPopoverRoute // Optional declarations
    
    case pastry
    case cake
    
    @ViewBuilder @MainActor
    var screen: some View {
        switch self {
            case .pastry: PastryScreen()
            case .cake: CakeScreen()
        }
    }
}
```

### Make your Root View

Set up a coordinator and ``SRRootView`` for your application.

Declaring a coordinator: 

```swift
@sRouteCoordinator(tabs: ["home", "setting"], stacks: "home", "setting")
@Observable
final class AppCoordinator { }
```

Declaring View of navigation destination:

```swift
@sRouteObserver(HomeRoute.self, SettingRoute.self)
struct RouteObserver { }
```

Setup Your App:

```swift
@sRoute
enum AppRoute {
    
    case startScreen
    case homeScreen
    
    @ViewBuilder @MainActor
    var screen: some View {
        switch self {
        case .startScreen:
            StartScreen()
                .transition(.scale(scale: 0.1).combined(with: .opacity))
        case .homeScreen:
            MainScreen()
                .transition(.opacity)
        }
    }
}

struct MainScreen: View {
    @Environment(AppCoordinator.self) var coordinator
    var body: some View {
        NavigationStack(path: coordinator.homePath) {
            HomeScreen()
                .routeObserver(RouteObserver.self)
        }
    }
}

@main
struct BookieApp: App {

    @State private var appCoordinator = AppCoordinator()
    @State private var context = SRContext()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(context: context, coordinator: appCoordinator) {
                SRSwitchView(startingWith: AppRoute.startScreen)
            }
            .environment(appCoordinator)
        }
    }
}
```
### Make a Screen and working with Router

Using the `onRouting(of:)` ViewModifier to observe router transition.

```swift
@sRoute
enum HomeRoute {
    case detail
    ...
}

struct HomeScreen: View {

    @State private var homeRouter = SRRouter(HomeRoute.self)

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
        await context.routing(.resetAll,
                              .select(tabItem: .home),
                              .push(route: HomeRoute.cake))
    }
}
```

Present a coordinator:

```swift
@sRouteCoordinator(stacks: "newStack")
final class OtherFlowCoordinator { }

struct OtherCoordinatorView: View {

    @Environment(SRContext.self) var context
    @State private var coordinator: OtherFlowCoordinator = .init()
    
    var body: some View {
        SRRootView(context: context, coordinator: coordinator) {
            NavigationStack(path: coordinator.newStackPath) {
                content()
                   .routeObserver(YourRouteObserver.self)
            }
        }
    }
    ...
}

...
...

router.trigger(to: .otherFlowCoordinator, with: .present)
```
Change Root:
```swift
router.switchTo(route: AppRoute.homeScreen)
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
 router.show(alert: YourAlertRoute.alert)
```
To dismiss a screen we use the `dismiss()` function.

```swift
router.dismiss()
```

To dismiss to root view we use the `dismissAll()` function.
Required the root view is a `SRRootView`

```swift
router.dismissAll()
```
To seclect the Tabbar item we use the `selectTabbar(at:)` function.

```swift
router.selectTabbar(at: AppCoordinator.SRTabItem.home)
```

sRouting also supported pop, pop to root and pop to a target function for the NavigationStack

```swift
router.pop()

router.popToRoot()

router.pop(to: HomeRoute.Paths.cake)
```

## 📃 License

`sRouting` is released under an MIT license. See [License.md](https://github.com/ThangKM/sRouting/blob/main/LICENSE) for more information.
