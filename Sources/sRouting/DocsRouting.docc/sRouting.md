# ``sRouting``

The lightweight navigation framework for SwiftUI.

## Overview

sRouting is built on SwiftUI's native navigation: `NavigationStack`, `TabView`, sheets, full-screen covers, alerts, confirmation dialogs, popovers and windows.

Declare your screens as ``SRRoute`` enums with the ``sRoute()`` macro, then drive navigation with an ``SRRouter`` from a view or a view model.
A coordinator declared with ``sRouteCoordinator(tabs:stacks:)`` owns the navigation stacks and the tab selection, and ``SRContext`` routes across the whole app, for example for deep links.

![A sRouting banner.](srouting_banner.png)

## Topics

### Essentials

- <doc:MeetsRouting>
- <doc:GettingStarted>

### Routes

- ``SRRoute``
- ``sRoute()``
- ``sRoutePath()``
- ``sSubRoute()``
- ``SRAlertRoute``
- ``SRConfirmationDialogRoute``
- ``SRPopoverRoute``

### Routing

- ``SRRouter``
- ``SRTriggerType``
- ``SRWindowTransition``
- ``SRContext``

### Coordinators and Navigation Stacks

- ``sRouteCoordinator(tabs:stacks:)``
- ``SRRouteCoordinatorType``
- ``SRCoordinatorEmitter``
- ``SRNavigationPath``
- ``sRouteObserver(_:)``
- ``SRRouteObserverType``

### Views

- ``SRRootView``
- ``SRSwitchView``
- ``NavigationRootView``
