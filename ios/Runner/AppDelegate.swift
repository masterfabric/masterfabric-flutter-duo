import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DuoBridgePlugin") {
      DuoBridgePlugin.register(with: registrar)
    }
  }
}

/// Bridges iPhone Duo fold information to Dart.
///
/// Flutter's `MediaQuery.displayFeatures` is only populated on Android, so on
/// iPhone Duo we read UIKit's reserved regions (iOS 27.1 SDK+):
///   - `.division`  -> the folding region (active only while partially open)
///   - `.occlusion` -> camera housings
/// plus the hinge status/angle from `UIHingeInteraction` and the
/// `UITraitCollection.verticalBarEdge` trait.
/// Channel `masterfabric/duo`: Dart calls `getState`, native pushes `update`.
final class DuoBridgePlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  private weak var registrar: FlutterPluginRegistrar?
  private var hingeStatus = "none"
  private var hingeAngleDegrees: Double = -1
  private weak var installedOn: UIView?

  init(channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
    self.channel = channel
    self.registrar = registrar
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "masterfabric/duo", binaryMessenger: registrar.messenger())
    let instance = DuoBridgePlugin(channel: channel, registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getState":
      installHingeInteractionIfNeeded()
      result(currentState())
    case "setTabs":
      result(setTabs(call.arguments as? [String: Any] ?? [:]))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private var flutterView: UIView? { registrar?.viewController?.view }

  private func installHingeInteractionIfNeeded() {
    guard let view = flutterView, installedOn !== view else { return }
    installedOn = view
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
        } else {
          self.hingeStatus = "none"
          self.hingeAngleDegrees = -1
        }
        // Reserved regions settle after layout: push now and once more shortly after.
        self.pushUpdate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
          self?.pushUpdate()
        }
      }
      view.addInteraction(interaction)
    }
  }

  // MARK: Native tab bar (iPhone Duo vertical bar)

  private lazy var tabOverlay = NativeSideTabs { [weak self] index in
    self?.channel.invokeMethod("tabSelected", arguments: index)
  }

  /// Native side navbar for the closed (outer) display, per the HIG
  /// "Designing for iPhone Duo": tab bars move to the side, into the vertical
  /// bar with the status bar and camera, on `verticalBarEdge`. The
  /// FlutterViewController stays the window root (swapping the root blanked
  /// the screen); the bar lives in the side safe-area strip so content never
  /// sits under it. Dart sends tabs / selection / visibility; taps come back
  /// as `tabSelected`. Returns whether the bar is showing.
  private func setTabs(_ args: [String: Any]) -> Bool {
    guard let view = flutterView else { return false }
    let tabs = (args["tabs"] as? [[String: Any]] ?? []).map {
      ($0["title"] as? String ?? "", $0["symbol"] as? String ?? "circle")
    }
    guard let vc = registrar?.viewController else { return false }
    return tabOverlay.apply(
      on: view, owner: vc, tabs: tabs, selected: args["selected"] as? Int ?? 0,
      visible: args["visible"] as? Bool ?? false)
  }

  private func pushUpdate() {
    channel.invokeMethod("update", arguments: currentState())
  }

  private func currentState() -> [String: Any] {
    var state: [String: Any] = [
      "supported": false,
      "hinge": hingeStatus,
      "angle": hingeAngleDegrees,
      "divisions": [[String: Any]](),
      "occlusions": [[String: Any]](),
    ]
    guard let view = flutterView else { return state }
    state["viewWidth"] = Double(view.bounds.width)
    state["viewHeight"] = Double(view.bounds.height)
    if #available(iOS 27.1, *) {
      state["supported"] = true
      func encode(_ regions: [UIView.ReservedRegion]) -> [[String: Any]] {
        regions.map { r in
          [
            "x": Double(r.frame.origin.x), "y": Double(r.frame.origin.y),
            "width": Double(r.frame.width), "height": Double(r.frame.height),
            "active": r.isActive,
          ]
        }
      }
      state["divisions"] = encode(view.reservedRegions(kind: .division, options: .includeInactive))
      state["occlusions"] = encode(view.reservedRegions(kind: .occlusion))
      // Edge where UIKit places its vertical bar (status bar / toolbars) on
      // iPhone Duo; Flutter draws its own navbar on the opposite side.
      switch view.traitCollection.verticalBarEdge {
      case .leading: state["verticalBarEdge"] = "leading"
      case .trailing: state["verticalBarEdge"] = "trailing"
      default: state["verticalBarEdge"] = "unspecified"
      }
    }
    return state
  }
}

/// Side navbar living in the vertical-bar strip (the side safe-area inset).
/// Prefers the system: a child `UITabBarController` sized to the strip, which
/// UIKit lays out vertically on iPhone Duo. If UIKit doesn't lay its bar out
/// vertically there, a native vertical bar (SF Symbol + title items, below
/// the camera / status bar) is used instead.
final class NativeSideTabs: NSObject {
  private let onSelect: (Int) -> Void
  private weak var host: UIView?
  private var system: UIViewController?
  private var custom: VerticalTabBar?
  private var useCustom = false
  private var tabs: [(String, String)] = []
  private var selected = 0
  private var visible = false
  private var observation: NSKeyValueObservation?

  init(onSelect: @escaping (Int) -> Void) { self.onSelect = onSelect }

  func apply(
    on host: UIView, owner: UIViewController, tabs: [(String, String)],
    selected: Int, visible: Bool
  ) -> Bool {
    if self.host !== host {
      self.host = host
      observation = host.observe(\.bounds, options: [.new]) { [weak self] _, _ in
        DispatchQueue.main.async { self?.layout() }
      }
    }
    self.tabs = tabs
    self.selected = selected
    self.visible = visible && !tabs.isEmpty
    if !useCustom, system == nil, #available(iOS 18.0, *) {
      let controller = SideTabBarController { [weak self] i in
        self?.selected = i
        self?.onSelect(i)
      }
      owner.addChild(controller)
      host.addSubview(controller.view)
      controller.didMove(toParent: owner)
      system = controller
    }
    layout()
    return self.visible && strip(in: host) != nil
  }

  /// The side strip UIKit reserves for its vertical bar (larger side inset).
  private func strip(in host: UIView) -> (CGRect, Bool)? {
    let safe = host.safeAreaInsets
    let b = host.bounds
    if safe.right >= 44, safe.right >= safe.left {
      return (CGRect(x: b.width - safe.right, y: 0, width: safe.right, height: b.height), false)
    }
    if safe.left >= 44 {
      return (CGRect(x: 0, y: 0, width: safe.left, height: b.height), true)
    }
    return nil
  }

  private func layout() {
    guard let host else { return }
    let area = strip(in: host)
    let show = visible && area != nil
    if #available(iOS 18.0, *), !useCustom, let controller = system as? SideTabBarController {
      controller.view.isHidden = !show
      guard show, let (rect, _) = area else { return }
      if controller.view.frame != rect { controller.view.frame = rect }
      controller.configure(tabs: tabs, selected: selected)
      host.bringSubviewToFront(controller.view)
      controller.view.layoutIfNeeded()
      let bar = controller.tabBar.convert(controller.tabBar.bounds, to: controller.view)
      if bar.height > bar.width, controller.view.bounds.intersects(bar), !controller.isTabBarHidden {
        return  // system vertical bar is in place
      }
      // UIKit didn't put its bar on the vertical axis here: use our own.
      controller.willMove(toParent: nil)
      controller.view.removeFromSuperview()
      controller.removeFromParent()
      system = nil
      useCustom = true
    }
    let bar = custom ?? {
      let bar = VerticalTabBar { [weak self] i in
        self?.selected = i
        self?.custom?.select(i)
        self?.onSelect(i)
      }
      host.addSubview(bar)
      custom = bar
      return bar
    }()
    bar.isHidden = !show
    guard show, let (rect, _) = area else { return }
    var top = host.safeAreaInsets.top
    if #available(iOS 27.1, *) {
      for r in host.reservedRegions(kind: .occlusion) where r.frame.intersects(rect) {
        top = max(top, r.frame.maxY)
      }
    }
    bar.frame = CGRect(
      x: rect.minX, y: top, width: rect.width,
      height: max(0, rect.maxY - host.safeAreaInsets.bottom - top))
    bar.setTabs(tabs, selected: selected)
    host.bringSubviewToFront(bar)
  }
}

/// System tab bar controller used only for its bar; content is see-through
/// and non-interactive so the Flutter view underneath stays in charge.
@available(iOS 18.0, *)
final class SideTabBarController: UITabBarController, UITabBarControllerDelegate {
  private let onSelect: (Int) -> Void
  private var signature: [String] = []

  init(onSelect: @escaping (Int) -> Void) {
    self.onSelect = onSelect
    super.init(nibName: nil, bundle: nil)
    delegate = self
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
  }

  func configure(tabs specs: [(String, String)], selected: Int) {
    let sig = specs.map { "\($0.0)|\($0.1)" }
    if sig != signature {
      signature = sig
      setTabs(
        specs.enumerated().map { i, spec in
          UITab(
            title: spec.0, image: UIImage(systemName: spec.1),
            identifier: "mf.tab.\(i)"
          ) { _ in
            let vc = UIViewController()
            vc.view.backgroundColor = .clear
            vc.view.isUserInteractionEnabled = false
            return vc
          }
        }, animated: false)
    }
    if tabs.indices.contains(selected), selectedTab !== tabs[selected] {
      selectedTab = tabs[selected]
    }
  }

  func tabBarController(
    _ tabBarController: UITabBarController, didSelectTab selectedTab: UITab,
    previousTab: UITab?
  ) {
    if let index = tabs.firstIndex(where: { $0 === selectedTab }) { onSelect(index) }
  }
}

/// Native vertical tab bar: SF Symbol over a short title per item, 44pt+
/// targets, stacked from the top of the strip (below the camera and status
/// bar), tinted like the system tab bar.
final class VerticalTabBar: UIView {
  private let onSelect: (Int) -> Void
  private let stack = UIStackView()
  private var signature: [String] = []

  init(onSelect: @escaping (Int) -> Void) {
    self.onSelect = onSelect
    super.init(frame: .zero)
    stack.axis = .vertical
    stack.alignment = .fill
    stack.spacing = 4
    stack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
    ])
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

  func setTabs(_ tabs: [(String, String)], selected: Int) {
    let sig = tabs.map { "\($0.0)|\($0.1)" }
    if sig != signature {
      signature = sig
      stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
      for (i, t) in tabs.enumerated() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: t.1)
        config.preferredSymbolConfigurationForImage = .init(pointSize: 20, weight: .medium)
        config.imagePlacement = .top
        config.imagePadding = 4
        config.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        var title = AttributedString(t.0)
        title.font = .systemFont(ofSize: 10, weight: .semibold)
        config.attributedTitle = title
        config.titleLineBreakMode = .byTruncatingTail
        let button = UIButton(configuration: config)
        button.tag = i
        button.accessibilityLabel = t.0
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        button.addAction(UIAction { [weak self] _ in self?.onSelect(i) }, for: .primaryActionTriggered)
        stack.addArrangedSubview(button)
      }
    }
    select(selected)
  }

  func select(_ index: Int) {
    for case let button as UIButton in stack.arrangedSubviews {
      let on = button.tag == index
      button.tintColor = on ? .tintColor : .secondaryLabel
      button.isSelected = on
      button.accessibilityTraits = on ? [.button, .selected] : .button
    }
  }
}
