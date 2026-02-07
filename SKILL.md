---
name: sRouting Development
description: Expert guidance on setting up sRouting and adding new screens/routes in a SwiftUI application.
---

# sRouting Development Skill

This skill provides step-by-step instructions for setting up the `sRouting` framework and adding new screens to a SwiftUI application.

## 1. Setting Up sRouting

When initializing a new project or adding `sRouting` to an existing one:

1.  **Add Dependency**:
    Add the `sRouting` package to your project.
    URL: `https://github.com/ThangKM/sRouting`

2.  **Define AppCoordinator**:
    Create a coordinator class using the `@sRouteCoordinator` macro.

    ```swift
    import sRouting
    import Observation

    @sRouteCoordinator(tabs: ["home", "settings"], stacks: "home", "settings")
    @Observable
    final class AppCoordinator { }
    ```

3.  **Configure the App Entry Point**:
    Modify your `@main` App struct to initialize `AppCoordinator` and `SRContext`, and wrap your root view in `SRRootView`.

    ```swift
    import SwiftUI
    import sRouting

    @main
    struct MyApp: App {
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

## 2. Setting Main Tab Bar and Navigation

1.  **Adding RouteObserver**:
    Define a generic observer view for your routable views. This is necessary for handling navigation events.

    ```swift
    import SwiftUI
    import sRouting
    
    // Register your @sRoute enums here
    @sRouteObserver(HomeRoute.self, SettingsRoute.self)
    struct RouteObserver { }
    ```

2.  **Define AppRoute and Main Tab Bar**:
    Define the high-level application routes (e.g., Start Screen, Main Tab Bar) and create the TabView. Ensure you attach the `.routeObserver` modifier to your navigation stacks.

    ```swift
    @sRoute
    enum AppRoute {
        case startScreen // Splash or Login
        case mainTabbar

        @ViewBuilder @MainActor
        var screen: some View {
            switch self {
            case .startScreen: Color.white // Replace with your Start/Splash View
            case .mainTabbar: MainTabbarView()
            }
        }
    }

    struct MainTabbarView: View {
        @Environment(AppCoordinator.self) var coordinator

        var body: some View {
            @Bindable var emitter = coordinator.emitter
            TabView(selection: $emitter.tabSelection) {
                NavigationStack(path: coordinator.homePath) {
                    Text("Home Screen") // Replace with HomeView
                        .routeObserver(RouteObserver.self) // <--- Add this
                }
                .tag(AppCoordinator.SRTabItem.homeItem)
                .tabItem { Label("Home", systemImage: "house") }

                NavigationStack(path: coordinator.settingsPath) {
                    Text("Settings Screen") // Replace with SettingsView
                        .routeObserver(RouteObserver.self) // <--- Add this
                }
                .tag(AppCoordinator.SRTabItem.settingsItem)
                .tabItem { Label("Settings", systemImage: "gear") }
            }
        }
    }
    ```

## 3. Creating a New Screen

When adding a new screen to the application:

1.  **Identify the Route Enum**:
    Determine which Route Enum the new screen belongs to (e.g., `HomeRoute`, `SettingsRoute`, or a new one).

2.  **Update the Route Enum**:
    -   Add a `case` for the new screen.
    -   Update the `screen` property (ViewBuilder) to return the new View for that case.

    ```swift
    @sRoute
    enum HomeRoute {
        case existingScreen
        case newFeature // <--- Add this

        @ViewBuilder @MainActor
        var screen: some View {
            switch self {
            case .existingScreen: ExistingView()
            case .newFeature: NewFeatureView() // <--- Add this
            }
        }
    }
    ```

3.  **Create the View**:
    Create the SwiftUI View. If the view needs to navigate, initialize `SRRouter`.

    ```swift
    struct NewFeatureView: View {
        // Initialize router with the associated Route Enum
        @State private var router = SRRouter(HomeRoute.self)

        var body: some View {
            VStack {
                Text("New Feature")
                Button("Go Back") {
                    router.dismiss()
                }
            }
            .onRouting(of: router) // <--- Bind the router
        }
    }
    ```

## 4. Manual Route Implementation (Advanced)

If you need to use a specific Actor or cannot use the standard `@sRoute` macro, use `@sRoutePath` and manually conform to `SRRoute`.

```swift
@sRoutePath
enum WorkerRoute: SRRoute {
    case taskList

    @MainActor @ViewBuilder
    var screen: some View {
        switch self {
        case .taskList: TaskListView()
        }
    }
}
```
