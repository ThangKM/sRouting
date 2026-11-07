# Getting Started with sRouting

Set up the `SRRootView` and interact with macros.

## Overview

Create your root view using `SRRootView`.
Declare your `SRRoute`.
Learn about macros and ViewModifiers.

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
    
    @sSubRoute
    case detail(DetailRoute)
    
    @ViewBuilder @MainActor
    var screen: some View {
        switch self {
            case .pastry: PastryScreen()
            case .cake: CakeScreen()
            case .detail(let route): route.screen
        }
    }
}
```

### Manual SRRoute Implementation via `@sRoutePath`

If you need to define paths for `SRRoute` manually, for example, to use with a specific actor (Swift Approachable concurrency), you can use the `@sRoutePath` macro.
This macro generates the `Paths` enum and `path` property but requires you to manually conform to the `SRRoute` protocol.

```swift
@sRoutePath
enum HomeRoute: SRRoute {

    typealias AlertRoute = YourAlertRoute // Optional declarations
    typealias ConfirmationDialogRoute = YourConfirmationDialogRoute // Optional declarations
    typealias PopoverRoute = YourPopoverRoute // Optional declarations
    
    case pastry
    case cake
    
    @sSubRoute
    case detail(DetailRoute)
    
    @ViewBuilder @MainActor
    var screen: some View {
        switch self {
            case .pastry: PastryScreen()
            case .cake: CakeScreen()
            case .detail(let route): route.screen
        }
    }
}
```

### Setting Up Your Root View

Start by configuring a coordinator and SRRootView for your application.

Declaring a Coordinator:

The macro generates an `SRTabItem` case for each tab name and an `SRNavigationPath` property named `<stack>Path` for each stack.

```swift
@sRouteCoordinator(tabs: ["home", "setting"], stacks: "home", "setting")
@Observable
final class AppCoordinator { }
```

Declaring the View for Navigation Destinations:

The `@sRouteObserver` macro generates a struct that handles the navigation destinations for your routes.

```swift
@sRouteObserver(HomeRoute.self, SettingRoute.self)
struct RouteObserver { }
```

Configuring Your App:

```swift
@sRoute
enum AppRoute {
    
    case startScreen
    case mainTabbar
    
    @ViewBuilder @MainActor
    var screen: some View {
        switch self {
        case .startScreen:
            StartScreen()
                .transition(.scale(scale: 0.1).combined(with: .opacity))
        case .mainTabbar:
            MainScreen()
                .transition(.opacity)
        }
    }
}

struct MainScreen: View {
    @Environment(AppCoordinator.self) var coordinator
    var body: some View {
        @Bindable var emitter = coordinator.emitter
        TabView(selection: $emitter.tabSelection) {
            NavigationStack(path: coordinator.homePath) {
                HomeScreen()
                    .routeObserver(RouteObserver.self)
            }
            .tag(AppCoordinator.SRTabItem.home.rawValue)
            
            NavigationStack(path: coordinator.settingPath) {
                SettingScreen()
                    .routeObserver(RouteObserver.self)
            }
            .tag(AppCoordinator.SRTabItem.setting.rawValue)
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
        }
    }
}
```
### Creating a Screen and Working with the Router

Use the `onRouting(of:)` view modifier to observe route transitions.

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

`SRContext` routes through the top-most coordinator, waiting between steps so each transition can finish.

```swift
...
.onOpenURL { url in
    Task {
        ...
        await context.routing(.resetAll,
                              .selectTabView(AppCoordinator.SRTabItem.home),
                              .push(route: HomeRoute.cake))
    }
}
```

Available steps: `.resetAll`, `.dismissAll`, `.popToRoot`, `.selectTabView(_:)`, `.push(route:)`, `.sheet(_:)`, `.present(_:)` (iOS), `.window(_:)` and `.wait(_:)`.

### Using Multiple Coordinators

To observe and open a new coordinator from the router, use `onRoutingCoordinator(_:context:)`.

Declaring Coordinator Routes:

```swift
@sRouteCoordinator(stacks: "newStack")
final class AnyCoordinator { }

struct AnyCoordinatorView<Content>: View where Content: View {

    @Environment(SRContext.self) var context
    @State private var coordinator: AnyCoordinator = .init()
    let content: () -> Content
    
    var body: some View {
        SRRootView(context: context, coordinator: coordinator) {
            NavigationStack(path: coordinator.newStackPath) {
                content()
                    .routeObserver(YourRouteObserver.self)
            }
        }
    }
}

@sRoute
enum CoordinatorsRoute {
    
    case notifications
    case settings
    
    @MainActor @ViewBuilder
    var screen: some View {
        switch self {
            case .notifications:
            AnyCoordinatorView { NotificationsScreen() }
            case .settings:
            AnyCoordinatorView { SettingsScreen() }
        }
    }
}
```

Handling Coordinator Routing in the Root View:
`Coordinators should be triggered from the root view using .onRoutingCoordinator.`

```swift
@main
struct BookieApp: App {

    @State private var appCoordinator = AppCoordinator()
    @State private var context = SRContext()
    
    var body: some Scene {
        WindowGroup {
            SRRootView(context: context, coordinator: appCoordinator) {
                SRSwitchView(startingWith: AppRoute.startScreen)
            }
            .onRoutingCoordinator(CoordinatorsRoute.self, context: context)
        }
    }
}
```
### Routing Actions

Present a new coordinator:
```swift
router.openCoordinator(route: CoordinatorsRoute.notifications, with: .present)
```
Change Root:
```swift
router.switchTo(route: AppRoute.mainTabbar)
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
To select the Tabbar item we use the `selectTabbar(at:)` function.

```swift
router.selectTabbar(at: AppCoordinator.SRTabItem.home)
```

Pop Actions in NavigationStack

```swift
router.pop()

router.popToRoot()

router.pop(to: HomeRoute.Paths.cake)
```

Customize the animation with a `Transaction`:

```swift
router.trigger(to: .cake, with: .push) {
    var transaction = Transaction()
    transaction.disablesAnimations = true
    return transaction
}
```

Open a window (macOS, iPadOS and visionOS):

```swift
router.openWindow(windowTrans: .init(windowId: "detail"))
router.openWindow(windowTrans: .init(value: book.id))
```

### Alerts, Confirmation Dialogs and Popovers

Declare the route types and set them on your ``SRRoute`` with `typealias AlertRoute`, `ConfirmationDialogRoute` and `PopoverRoute`:

```swift
enum YourAlertRoute: SRAlertRoute {
    case lostConnection

    var titleKey: LocalizedStringKey { "Lost Connection" }
    var message: some View { Text("Please check your connection") }
    var actions: some View { Button("OK") { } }
}

enum YourConfirmationDialogRoute: SRConfirmationDialogRoute {
    case deleteBook

    var identifier: String { "deleteBook" }
    var titleKey: LocalizedStringKey { "Delete this book?" }
    var titleVisibility: Visibility { .visible }
    var message: some View { Text("This can't be undone.") }
    var actions: some View { Button("Delete", role: .destructive) { } }
}
```

```swift
router.show(alert: YourAlertRoute.lostConnection)
router.show(dialog: YourConfirmationDialogRoute.deleteBook)
router.show(popover: YourPopoverRoute.info)
```

On iPad and on iOS 26 or later, a confirmation dialog is anchored to a view. On iPad and macOS, so is a popover.
Attach the anchor modifier to the view the dialog or popover should point at:

```swift
Button("Delete") {
    router.show(dialog: .deleteBook)
}
.onDialogRouting(of: router, for: .deleteBook)

Button("Info") {
    router.show(popover: .info)
}
.onPopoverRouting(of: router, for: .info)
```

### Observing Navigation Changes

```swift
TabView(selection: $emitter.tabSelection) { ... }
    .onTabSelectionChange { selection in ... }   // the selected tab changed
    .onDoubleTapTabItem { selection in ... }     // the selected tab was tapped twice, e.g. scroll to top

NavigationStack(path: coordinator.homePath) {
    HomeScreen()
        .onNaviStackChange { oldPaths, newPaths in ... } // apply inside the stack
}

SomeScreen()
    .onDismissAllChange { ... }                  // `dismissAll()` was triggered
```

## 📃 License

`sRouting` is released under an MIT license. See [License.md](https://github.com/ThangKM/sRouting/blob/main/LICENSE) for more information.
