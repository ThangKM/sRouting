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

Setup a context and ``SRRootView`` for your app

Declaring Context: 

```swift
@sRContext(tabs: ["home", "setting"], stacks: "home", "setting")
struct SRContext { }
```

Declaring View of navigation destination:

```swift
@sRouteObserve(HomeRoute.self, SettingRoute.self)
struct ObserveView<Content>: View where Content: View { }
```

Setup Your App:

```swift
@main
struct BookieApp: App { 
    let context = SRContext()
    ...
    var body: some Scene {

        WindowGroup {
            SRRootView(context: context) {
                @Bindable var tabSelection = context.tabSelection
                TabView(selection: $tabSelection.selection) {
                    NavigationStack(path: context.homePath) {
                        AppRoute.home.screen
                            .routeObserver(RouteObserver.self)
                    }.tabItem {
                        Label("Home", systemImage: "house")
                    }.tag(SRTabItem.home.rawValue)
                    
                    NavigationStack(path: context.settingPath) {
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
        await context.routing(.resetAll,.select(tabItem: .home),
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
