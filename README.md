# MasterFabric Flutter Duo

<p align="center">
  <img src="docs/screenshots/duo_demo.gif" width="420" alt="MasterFabric Flutter Duo demo on iPhone Duo">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/iOS-27.1-000000?logo=apple&logoColor=white" alt="iOS 27.1">
  <img src="https://img.shields.io/badge/device-iPhone%20Duo-5E5CE6" alt="iPhone Duo">
  <img src="https://img.shields.io/badge/state-flutter__bloc-13B9FD" alt="flutter_bloc">
</p>

<p align="center"><sub>One Flutter codebase that follows the fold: the closed display with the native side tab bar, then unfolded into a split view on the inner display.</sub></p>

**Building Flutter products for iPhone Duo devices.**

This is the mobile version of [masterfabric.co](https://masterfabric.co), built in Flutter and designed for **iPhone Duo**, Apple's foldable iPhone. It follows Apple's [Human Interface Guidelines for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo) and uses the real iOS 27.1 APIs (`UIHingeInteraction`, `UIView.reservedRegions`, `UITraitCollection.verticalBarEdge` and the system vertical tab bar) through a small platform channel.

> **Platform:** iOS only. The project ships just the `ios/` runner and targets iPhone Duo on iOS 27.1; Android, web and desktop runners were removed on purpose.

You can use it as a reference for:

- adapting one Flutter codebase to every iPhone Duo posture: closed, book, flat and tabletop;
- handing navigation to the **native side tab bar** on the closed (outer) display, without giving up the Flutter view;
- structuring a Flutter app with the [masterfabric_core](https://github.com/masterfabric-mobile/masterfabric_core) and [osmea](https://github.com/masterfabric-mobile/osmea) conventions: blocs with explicit events, base view models and DI.

<p align="center">
  <img src="docs/screenshots/closed_home.png" width="190" alt="Home on the closed iPhone Duo with the system side tab bar">
  <img src="docs/screenshots/closed_services.png" width="190" alt="Services">
  <img src="docs/screenshots/closed_work.png" width="190" alt="Work">
  <img src="docs/screenshots/closed_contact.png" width="190" alt="Contact">
</p>
<p align="center"><sub>Closed iPhone Duo (outer display, iOS 27.1 simulator): Home, Services, Work and Contact. The system vertical tab bar sits on the <code>verticalBarEdge</code> side, below the clock and the always-visible camera, and the content is inset so the bar never covers it.</sub></p>

---

## Contents

- [Features by posture](#features-by-posture)
- [iPhone Duo design in pictures](#iphone-duo-design-in-pictures)
- [Apple documentation map](#apple-documentation-map)
- [Architecture](#architecture)
- [State management](#state-management)
- [Platform channel: `masterfabric/duo`](#platform-channel-masterfabricduo)
- [Running on the iPhone Duo simulator](#running-on-the-iphone-duo-simulator)
- [Tests and analysis](#tests-and-analysis)
- [Limitations](#limitations)
- [Roadmap](#roadmap)

---

## Features by posture

The app always shows **one** navigation surface per posture, and the content always stays scrollable and uncovered.

<p align="center">
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-poses~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-poses@2x.png" width="760" alt="Six iPhone Duo poses, from closed to partially folded, flat and standing"></picture>
</p>

<p align="center"><sub>The poses iPhone Duo supports. This app maps them to four layouts: closed, book, flat and tabletop.<br>Image: Apple Human Interface Guidelines, <a href="https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Device-poses">Designing for iPhone Duo, Device poses</a>.</sub></p>

| Posture | How it's detected | Navigation | Content |
| --- | --- | --- | --- |
| **Closed** (outer display) | `UIHingeInteraction` reports `.closed` and the window is single-pane | The **system vertical tab bar** (`UITabBarController` with `UITab`s, SF Symbols) on the `verticalBarEdge` side, in the side safe-area strip | A full-height scrolling page, inset by the side safe area; the wordmark app bar has a Contact shortcut |
| **Book** (partly open, vertical fold) | Hinge `.partiallyOpen` plus a vertical `division` reserved region | The section list on the left pane; you can long-press a section and **drag it across the fold** | The selected section on the right pane; the hinge is never drawn over |
| **Flat** (fully open) | Hinge `.fullyOpen` | The same two-pane layout as book | The same; the state (scroll offset, expanded cards) survives fold and unfold through `GlobalKey`s |
| **Tabletop** (partly open, horizontal fold) | Hinge `.partiallyOpen` plus a horizontal `division` | A **control deck** below the fold with evenly sized section tiles | Content above the fold |
| **Regular iPhone / no bridge** | No hinge, `verticalBarEdge == .unspecified` | A floating Flutter pill bar | Full screen |

The split decision (`DualPaneGeometry.resolve`) uses, in order: Flutter `DisplayFeature`s (once the engine provides them, see [Limitations](#limitations)), then the native `reservedRegions(kind: .division)`, then a width breakpoint. Camera housings (`occlusion` regions) are merged into the safe-area padding, so nothing renders under them.

If the native bar can't be shown but the system reports a vertical bar edge, a Flutter `DuoNavRail` is used as the fallback, on that edge. It's never shown at the same time as another navigation surface.

## iPhone Duo design in pictures

Apple's diagrams for the ideas this app is built on, each with a note on how the app applies it. The images load from developer.apple.com and are not copied into this repository.

### Anatomy: two displays and a hinge

<p align="center">
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-device-layout-outer~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-device-layout-outer@2x.png" width="300" alt="Outer display of iPhone Duo with the hinge and the outer front-facing camera"></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-device-layout-inner~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-device-layout-inner@2x.png" width="400" alt="Inner display of iPhone Duo with the hinge and the inner front-facing camera"></picture>
</p>

<p align="center"><sub>Outer display (left) and inner display (right). The app reads the hinge with <code>UIHingeInteraction</code> and picks one layout per display.<br>Image: Apple Human Interface Guidelines, <a href="https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Anatomy">Designing for iPhone Duo, Anatomy</a>.</sub></p>

### Vertical controls: bars move to the side

<p align="center">
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-tab-bar-toolbar-layout~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-tab-bar-toolbar-layout@2x.png" width="360" alt="Outer display with the Dynamic Island, status bar, toolbar and tab bar stacked on the trailing edge"></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-multitasking~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-multitasking@2x.png" width="460" alt="Two apps in Split View on the inner display, each with its controls on its outer edge"></picture>
</p>

<p align="center"><sub>On the closed display, the app hands navigation to the system vertical tab bar on the <code>verticalBarEdge</code> side, below the camera, through the <code>setTabs</code> channel call.<br>Image: Apple Human Interface Guidelines, <a href="https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Vertical-controls">Designing for iPhone Duo, Vertical controls</a>.</sub></p>

### Reserved regions: cameras and the fold

<p align="center">
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-safe-area-outer-camera~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-safe-area-outer-camera@2x.png" width="340" alt="Outer display with the outer camera region"></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-safe-area-inner-camera~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-safe-area-inner-camera@2x.png" width="420" alt="Inner display with the folding region and the inner camera region"></picture>
</p>

<p align="center"><sub>The app reads these with <code>reservedRegions(kind: .occlusion)</code> for the cameras, merged into the safe-area padding, and <code>.division</code> for the fold, where the two panes split.<br>Image: Apple Human Interface Guidelines, <a href="https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Reserved-regions">Designing for iPhone Duo, Reserved regions</a>.</sub></p>

### One more level of hierarchy on the inner display

<p align="center">
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-mail-compact~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-mail-compact@2x.png" width="260" alt="Mail on the outer display showing one email"></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-mail-full~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-mail-full@2x.png" width="500" alt="Mail on the inner display with the email list and an email side by side"></picture>
</p>

<p align="center"><sub>Closed shows one level (here, the current section); open shows the section list next to the selected section. Same state on both displays.<br>Image: Apple Human Interface Guidelines, <a href="https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Best-practices">Designing for iPhone Duo, Best practices</a>.</sub></p>

### Split views that adapt to the fold

<p align="center">
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-notes-sidebar-open~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-notes-sidebar-open@2x.png" width="400" alt="Notes fully open with a narrower list pane and a wider note pane"></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-notes-sidebar-folded~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-notes-sidebar-folded@2x.png" width="400" alt="Notes partially folded with two equal panes, one on each side of the fold"></picture>
</p>

<p align="center"><sub>Flat (left) and partially folded (right). In book posture, the app splits exactly at the <code>.division</code> region so nothing is drawn over the hinge.<br>Image: Apple Human Interface Guidelines, <a href="https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Reserved-regions">Designing for iPhone Duo, Reserved regions</a>.</sub></p>

### Arrangement views

<p align="center">
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-view-layout-split~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-view-layout-split@2x.png" width="400" alt="Split arrangement with a primary view and a secondary view side by side"></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-view-layout-overlay~dark@2x.png"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/designing-for-iphone-view-layout-overlay@2x.png" width="400" alt="Overlay arrangement with a smaller primary view on top of a secondary view"></picture>
</p>

<p align="center"><sub>Split (left) and overlay (right) arrangements, from <code>UIArrangementViewController</code>. The app's <code>DualPane</code> layout follows the split model; navigation stays outside it, as the HIG recommends.<br>Image: Apple Human Interface Guidelines, <a href="https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Arrangement-views">Designing for iPhone Duo, Arrangement views</a>.</sub></p>

## Apple documentation map

| Feature in this app | Apple guidance / API |
| --- | --- |
| Side tab bar on the closed display; no override of bar placement | HIG: [Designing for iPhone Duo, Vertical controls](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Vertical-controls): *"the system places toolbars and tab bars on the side to maximize the vertical space for content"*, *"In general, don't override the default bar placement"* |
| A title **and** a symbol for each tab | HIG: *"Provide both a title and a symbol for each toolbar item"*; [`UITab`](https://developer.apple.com/documentation/uikit/uitab), [`UITabBarController`](https://developer.apple.com/documentation/uikit/uitabbarcontroller) |
| Content inset by the vertical bar's safe area | HIG: *"Use safe areas to make sure controls don't cover your content"*; [`safeAreaInsets`](https://developer.apple.com/documentation/uikit/uiview/safeareainsets) |
| Bar placed on the system's edge | [`UITraitCollection.verticalBarEdge`](https://developer.apple.com/documentation/uikit/uitraitcollection/verticalbaredge), [`UIVerticalBarCompressionBehavior`](https://developer.apple.com/documentation/uikit/uiverticalbarcompressionbehavior) |
| Tabs start below the always-visible outer camera | HIG: *"The outer front-facing camera is in the corner and is always visible, vertically aligned with controls on the side"*; [`reservedRegions(kind:options:)`](https://developer.apple.com/documentation/uikit/uiview/reservedregions(kind:options:)) with `.occlusion` |
| Hinge status and angle drive the posture | [`UIHingeInteraction`](https://developer.apple.com/documentation/uikit/uihingeinteraction), [`UIHinge`](https://developer.apple.com/documentation/uikit/uihinge) |
| Two panes split exactly at the fold | HIG: [Split views](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Split-views); [`UIView.ReservedRegion`](https://developer.apple.com/documentation/uikit/uiview/reservedregion) with `.division`; [`UIArrangementViewController`](https://developer.apple.com/documentation/uikit/uiarrangementviewcontroller) |
| Layout adapts across postures with continuity | HIG: [Dynamic layouts](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Dynamic-layouts); [Preparing your app for iPhone Duo](https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo) |
| Testing every posture | [Device Hub](https://developer.apple.com/documentation/xcode/device-hub) |

Tech talks:

- [Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111466)
- [Raise the bar with iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111462)
- [Strike a pose with adaptive layouts on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111463)

## Architecture

The project mirrors two MasterFabric references:

- [**masterfabric_core**](https://github.com/masterfabric-mobile/masterfabric_core): its base view model pattern (here as `BaseViewModelBloc`, the Bloc counterpart of `BaseViewModelCubit`), Equatable events and states, a `get_it` service locator, and helpers under `helper/`.
- [**osmea**](https://github.com/masterfabric-mobile/osmea): `lib/app/{core/bloc, views/view_<name>/{<name>_view.dart, models, widgets}, widgets}` and package imports.

```text
lib/
├── main.dart                         # bootstrap: DI, DuoBridge.start(), runApp
└── app/
    ├── app.dart                      # MasterFabricApp: MultiBlocProvider + MaterialApp
    ├── core/
    │   ├── base/base_view_model_bloc.dart
    │   ├── bloc/
    │   │   ├── duo/{duo_bloc,duo_event,duo_state}.dart     # posture + native tab bar
    │   │   └── navigation/{navigation_bloc,navigation_event,navigation_state}.dart
    │   └── di/injection.dart         # get_it registrations
    ├── helper/layout/duo/
    │   ├── duo_bridge.dart           # masterfabric/duo MethodChannel client
    │   ├── fold_info.dart            # FoldInfo, HingeStatus, ReservedRegion, VerticalBarEdge
    │   ├── dual_pane_layout.dart     # DualPaneGeometry, DualPane, occlusion insets
    │   └── duo_nav_rail.dart         # Flutter fallback rail + HingeGlyph
    ├── models/site_content.dart      # masterfabric.co copy
    ├── theme/app_theme.dart          # MfColors + AppTheme
    ├── views/
    │   ├── view_shell/               # ShellView: picks the nav per posture
    │   │   ├── shell_view.dart
    │   │   ├── models/shell_section.dart
    │   │   └── widgets/section_list_widget.dart
    │   ├── view_home/home_view.dart
    │   ├── view_services/services_view.dart
    │   ├── view_work/work_view.dart
    │   └── view_contact/contact_view.dart
    └── widgets/                      # common, links, mf_logo, pill_nav_bar
ios/Runner/AppDelegate.swift          # DuoBridgePlugin, NativeSideTabs, SideTabBarController
test/                                 # widget, Duo layout and bloc tests
```

## State management

App state lives in two blocs (`flutter_bloc`). Both extend `BaseViewModelBloc`, change state only in `on<Event>` handlers, and are registered in `get_it`. Widgets dispatch events with `context.read<XBloc>().add(...)`.

| Bloc | Events | State | Source of truth |
| --- | --- | --- | --- |
| `NavigationBloc` | `NavigationSectionSelected(index)` | `NavigationState(index)` | Taps from the pill bar, section list, tabletop deck, CTAs, drag-and-drop, **and the native side tab bar** (`tabSelected`) |
| `DuoBloc` | `DuoBridgeChanged(info, nativeTabsShown)`, `DuoNativeTabsSyncRequested(tabs, selected, visible)` | `DuoState(info: FoldInfo, nativeTabsShown)` | `DuoBridge` (`update` pushes, `getState` on metrics changes, and the `setTabs` result) |

```text
UIHingeInteraction / reservedRegions / verticalBarEdge
        │  "update" (native → Dart)
        ▼
   DuoBridge ──notifies──▶ DuoBloc (DuoBridgeChanged) ──▶ BlocBuilder<DuoBloc> in ShellView
        ▲                                     │ picks the layout for the posture
        │ "setTabs" (Dart → native)           │
        └── DuoBloc ◀ DuoNativeTabsSyncRequested ┘ (closed + single pane ⇒ visible)

Native tab tap ─ "tabSelected" ─▶ DuoBridge.onNativeTabSelected ─▶ NavigationBloc ◀ NavigationSectionSelected
Flutter nav taps ───────────────────────────────────────────────▶ NavigationBloc ◀ NavigationSectionSelected
NavigationBloc ─▶ ShellView rebuilds ─▶ setTabs(selected) keeps the native bar in sync
```

`ShellView` keeps only UI resources (page `GlobalKey`s for state continuity across fold and unfold); there is no `setState`-driven app state.

## Platform channel: `masterfabric/duo`

A single `MethodChannel('masterfabric/duo')`, implemented by `DuoBridgePlugin` in `ios/Runner/AppDelegate.swift` and consumed by `DuoBridge` in `lib/app/helper/layout/duo/duo_bridge.dart`.

| Method | Direction | Arguments | Returns |
| --- | --- | --- | --- |
| `getState` | Dart → iOS | none | State map (below); installs the hinge interaction on first call |
| `update` | iOS → Dart | State map | none; pushed on every hinge change and again 0.35 s later, when the reserved regions have settled |
| `setTabs` | Dart → iOS | `{tabs: [{title, symbol}], selected: int, visible: bool}` | `bool`: whether the native side tab bar is showing |
| `tabSelected` | iOS → Dart | `int` tab index | none |

State map:

```json
{
  "supported": true,
  "hinge": "closed | partiallyOpen | fullyOpen | none | unknown",
  "angle": 180.0,
  "divisions":  [{ "x": 0, "y": 0, "width": 0, "height": 0, "active": true }],
  "occlusions": [{ "x": 0, "y": 0, "width": 0, "height": 0, "active": true }],
  "viewWidth": 402.0,
  "viewHeight": 874.0,
  "verticalBarEdge": "leading | trailing | unspecified"
}
```

### iOS side (Swift)

Hinge status and angle come from `UIHingeInteraction` (iOS 27.1+):

```swift
if #available(iOS 27.1, *) {
  let interaction = UIHingeInteraction { [weak self] _, update in
    guard let self else { return }
    if let hinge = update.hinge {
      switch hinge.status {
      case .closed: self.hingeStatus = "closed"
      case .partiallyOpen: self.hingeStatus = "partiallyOpen"
      case .fullyOpen: self.hingeStatus = "fullyOpen"
      default: self.hingeStatus = "unknown"
      }
      self.hingeAngleDegrees = Double(hinge.angle) * 180.0 / Double.pi
    }
    self.pushUpdate()  // channel.invokeMethod("update", arguments: currentState())
  }
  view.addInteraction(interaction)
}
```

Reserved regions and the vertical bar edge:

```swift
if #available(iOS 27.1, *) {
  state["divisions"]  = encode(view.reservedRegions(kind: .division, options: .includeInactive))
  state["occlusions"] = encode(view.reservedRegions(kind: .occlusion))
  switch view.traitCollection.verticalBarEdge {
  case .leading:  state["verticalBarEdge"] = "leading"
  case .trailing: state["verticalBarEdge"] = "trailing"
  default:        state["verticalBarEdge"] = "unspecified"
  }
}
```

**The native side tab bar** (`NativeSideTabs` and `SideTabBarController`):

- A `UITabBarController` is added as a **child** of the `FlutterViewController`. Its view frame is the side safe-area strip that UIKit reserves for the vertical bar, so UIKit lays its tab bar out vertically there.
- The tab content controllers are transparent and non-interactive, so the Flutter view stays in charge of the content.
- The `FlutterViewController` **stays the window root**. Swapping the root for a `UITabBarController` detaches the Flutter view and blanks the screen.
- If UIKit doesn't lay the bar out vertically, a native `VerticalTabBar` (SF Symbol above a title, 56 pt minimum) is used, placed below the camera occlusion.

```swift
let controller = SideTabBarController { [weak self] i in self?.onSelect(i) }  // → "tabSelected"
owner.addChild(controller)            // owner = FlutterViewController (still the root)
host.addSubview(controller.view)      // host  = Flutter view
controller.didMove(toParent: owner)
controller.view.frame = sideStrip     // e.g. the 84 pt trailing safe-area strip
controller.setTabs(specs.enumerated().map { i, spec in
  UITab(title: spec.0, image: UIImage(systemName: spec.1), identifier: "mf.tab.\(i)") { _ in
    let vc = UIViewController(); vc.view.backgroundColor = .clear
    vc.view.isUserInteractionEnabled = false; return vc
  }
}, animated: false)
```

### Dart side

```dart
// lib/app/helper/layout/duo/duo_bridge.dart
_channel.setMethodCallHandler((call) async {
  switch (call.method) {
    case 'update':
      _apply(call.arguments);                      // → FoldInfo.fromMap → notifyListeners
    case 'tabSelected':
      final i = call.arguments;
      if (i is int) onNativeTabSelected?.call(i);  // → NavigationBloc ◀ NavigationSectionSelected
  }
});

// ShellView: hand navigation to the native bar while the Duo is closed.
context.read<DuoBloc>().add(
  DuoNativeTabsSyncRequested(
    tabs: [for (final s in kShellSections) (title: s.item.label, symbol: s.symbol)],
    selected: navigationIndex,
    visible: !geometry.isDual && fold.hinge == HingeStatus.closed,
  ),
);
```

`DuoBridge.syncNativeTabs` de-duplicates identical calls, and Flutter keeps its own navigation until iOS confirms (`true`) that the native bar is showing. That way the app is never left without a navigation surface.

## Running on the iPhone Duo simulator

Requirements: Xcode with the iOS 27.1 SDK and the **iPhone Duo** simulator runtime, and Flutter stable (tested on 3.47.8).

```bash
flutter pub get
xcrun simctl list devices | grep "iPhone Duo"    # find the simulator id
xcrun simctl boot <DUO_SIM_ID>
flutter run -d <DUO_SIM_ID>
```

- Change the posture (closed, book, flat, tabletop) from Xcode's [Device Hub](https://developer.apple.com/documentation/xcode/device-hub).
- Open a section at launch with `flutter run -d <id> --dart-define=MF_TAB=2` (0 Home, 1 Services, 2 Work, 3 Contact).
- Capture the outer display with `xcrun simctl io <id> screenshot --display=1 out.png`.

## Tests and analysis

```bash
flutter analyze   # strict: strict-casts/inference/raw-types, public_member_api_docs, package imports…
flutter test      # widget + Duo layout + bloc tests
```

- `test/widget_test.dart`: one nav per posture, the native tab bar hand-off, drag across the fold, tabletop.
- `test/duo_layout_test.dart`: geometry from display features, reserved regions and breakpoints; occlusion insets; the rail fallback.
- `test/bloc_test.dart`: `NavigationBloc` (clamping, `NavigationSectionSelected`, native taps, detaching on close) and `DuoBloc` (mirroring the bridge, `DuoBridgeChanged`, `DuoNativeTabsSyncRequested`, closing).

## Limitations

- **Flutter doesn't report iPhone Duo display features yet.** On iOS, `MediaQuery.displayFeatures` is empty, which is why this app reads the hinge and reserved regions through its own channel. Upstream tracking:
  - [flutter/flutter#192515](https://github.com/flutter/flutter/issues/192515): *Proposal: populate MediaQuery.displayFeatures on iOS for iPhone Duo*.
  - [flutter/flutter#193025](https://github.com/flutter/flutter/pull/193025): *Populate display features from the iPhone Duo hinge and reserved regions*.

  Once that lands, `DualPaneGeometry` already prefers `DisplayFeature`s, and the channel remains for the native tab bar.
- The side tab bar is UIKit, layered over the Flutter view. Its look follows the system, not the Flutter theme.
- The still screenshots above are from the outer (closed) display; the demo GIF at the top shows the unfold and the split view on the inner display.
- iOS only by design: there are no Android, web or desktop runners. In widget tests (no native channel), the layout falls back to breakpoints and the pill bar.

## Roadmap

- [ ] Drop the custom geometry path when flutter/flutter#193025 ships, and keep the channel for the bars only.
- [ ] Golden tests for the inner-display postures (book, flat and tabletop).
- [ ] A native vertical **toolbar** (`UIBarButtonItemVisibilityPriority`, overflow) for section actions.
- [ ] Extract `masterfabric/duo` into a reusable Flutter plugin package (`masterfabric_duo`).
- [ ] Localization (slang) and hydrated state, as in masterfabric_core.
- [ ] Routing with go_router once the app has deep-linkable detail pages.

---

© 2026 MasterFabric. Built by [MasterFabric](https://masterfabric.co).
