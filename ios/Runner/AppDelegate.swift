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
