# Getting Started with sRouting

Set up ``RootView`` and working with ``Router``

## Overview

Create your root view with ``RootView``.
Declares your ``Route``.
Working with ``ScreenView`` and ``Router``.

### Create a Route

To create a ``Route`` we have to conform the ``Route`` Protocol.

```swift
enum AppRoute: Route {
    case login
    case home

    var screen: some View {
        switch self {
            case .login: LoginScreen()
            case .home: HomeScreen()
        }
    }
}
```

### Make your Root View

Setup the ``RootView`` for your app

```swift
@main
struct SequenceApp: App { 
    ...
    @SceneBuilder
    var body: some Scene { 
        WindowGroup {
            RootView {
                NavigationView {
                    AppRoute.home.screen
                }
                .navigationViewStyle(.stack)
            }
        }
    }
}
```
### Make a Screen and working with Router

Build a screen with ``ScreenView``, ``ScreenView`` will create a hidden NavigatorView at below content view
in a ZStack.
The NavigatorView will handle transactions that are emited by ``Router``

```swift
struct HomeScreen: View {

@StateObject
private var router: Router<AppRoute> = .init()

var body: some View {
    ScreenView(router: router) {
    ...
    }
}
```


To navigate to a screen that must be in AppRoute 
we use the ``Router/trigger(to:with:)`` function in the ``Router``

Push:
```swift
router.trigger(to: .loginScreen, with: .push)
```
Present full screen:
```swift
router.trigger(to: .loginScreen, with: .present)
```
Sheet:
```swift
router.trigger(to: .loginScreen, with: .sheet)
```

To show an error message we use the ``Router/show(error:and:)`` function.

```swift
router.show(error:NetworkingError.lossConnection)
```

To dismiss or pop screen we use the ``Router/dismiss()`` function.

```swift
router.dismiss()
```

To dismiss to root view we use the ``Router/dismissAll()`` function.
Required the root view is a ``RootView``

```swift
router.dismissAll()
```

### Using Router in a ViewModel

Also the router can be used in a ViewModel.

```swift
class HomeViewModel: Router<AppRoute> {
...
}

```

```swift
struct HomeScreen: View {

@StateObject
private var viewModel: HomeViewModel = .init()

var body: some View {
    ScreenView(router: viewModel) {
    ...
    }
}
```
Now you can navigate to new screen in HomeViewModel, that's cool right?

### Note
Make sure the transition is performed on MainThread.

### Conclusion
sRouting is a lightweight framework and flexiable, so you can handle the
navigations by the way you want to.
