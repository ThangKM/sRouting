# 🏃‍♂️ Getting Started with sRouting

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
final class AppCoordinator { }
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

    @State private var context = SRContext()
    @State private var coordinator = AppCoordinator()
    ...
    var body: some Scene {

        WindowGroup {
            SRRootView(context: context, coordinator: coordinator) {
                @Bindable var emitter = coordinator.emitter
                TabView(selection: $emitter.tabSelection) {
                    NavigationStack(path: coordinator.homePath) {
                        AppRoute.home.screen
                            .routeObserver(RouteObserver.self)
                    }.tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(AppCoordinator.SRTabItem.home.rawValue)
                    
                    NavigationStack(path: coordinator.settingPath) {
                        AppRoute.setting.screen
                            .routeObserver(RouteObserver.self)
                    }.tabItem {
                        Label("Setting", systemImage: "gear")
                    }.tag(AppCoordinator.SRTabItem.setting.rawValue)
                }
                .onDoubleTapTabItem { ... }
                .onTabSelectionChange { ... }
            }
            .onOpenURL { url in
                Task {
                    ...
                    await context.routing(.resetAll,.select(tabItem: .home),
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
 router.show(alert: .yourAlert)
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
router.selectTabbar(at: AppCoordinator.SRTabItem.home)
```

sRouting also supported pop, pop to root and pop to a target function for the NavigationStack

```swift
router.pop()

router.popToRoot()

router.pop(to: HomeRoute.cake)
```
