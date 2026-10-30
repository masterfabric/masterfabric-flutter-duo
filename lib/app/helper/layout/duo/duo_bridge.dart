import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_flutter/app/helper/layout/duo/fold_info.dart';

/// Listens to the native `masterfabric/duo` channel (see ios/Runner/AppDelegate.swift).
///
/// Re-queries whenever the window metrics change (fold/unfold resizes the
/// app on iPhone Duo) and accepts pushes from `UIHingeInteraction`.
class DuoBridge extends ChangeNotifier with WidgetsBindingObserver {
  DuoBridge._();

  /// Process-wide bridge instance.
  static final DuoBridge instance = DuoBridge._();
  static const _channel = MethodChannel('masterfabric/duo');

  FoldInfo _info = FoldInfo.none;

  /// Latest posture reported by the native side.
  FoldInfo get info => _info;

  bool _started = false;

  /// Installs the channel handler and fetches the first state. iOS only; idempotent.
  void start() {
    if (_started) return;
    _started = true;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'update':
          _apply(call.arguments);
        case 'tabSelected':
          final i = call.arguments;
          if (i is int) onNativeTabSelected?.call(i);
      }
    });
    WidgetsBinding.instance.addObserver(this);
    unawaited(refresh());
  }

  @override
  void didChangeMetrics() {
    unawaited(refresh());
    // Reserved regions update after layout; check again once things settle.
    Future<void>.delayed(const Duration(milliseconds: 400), refresh);
  }

  /// Asks the native side for the current state (`getState`).
  Future<void> refresh() async {
    try {
      _apply(await _channel.invokeMethod<Object?>('getState'));
    } on MissingPluginException {
      // Not running with the native bridge (e.g. tests, other platforms).
    } on PlatformException {
      // Ignore: fall back to Flutter display features / breakpoints.
    }
  }

  /// Overrides [info] in tests.

  @visibleForTesting
  void debugSet(FoldInfo info) => _setInfo(info);

  /// Called when the user taps a tab in the native (UIKit) tab bar.
  void Function(int index)? onNativeTabSelected;

  bool _nativeTabsShown = false;

  /// Whether the native UIKit tab bar is currently the app's navigation
  /// (iPhone Duo closed: UIKit renders it in the system vertical bar).
  bool get nativeTabsShown => _nativeTabsShown;

  /// Overrides [nativeTabsShown] in tests.

  @visibleForTesting
  void debugSetNativeTabsShown(bool shown) {
    _nativeTabsShown = shown;
    notifyListeners();
  }

  String? _lastTabsCall;

  /// Sends the tabs (title + SF Symbol), the selected index and whether the
  /// native tab bar should be shown. Flutter keeps its own navigation until
  /// the native side confirms it is showing.
  Future<void> syncNativeTabs({
    required List<({String title, String symbol})> tabs,
    required int selected,
    required bool visible,
  }) async {
    if (!_started || kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    final args = {
      'tabs': [
        for (final t in tabs) {'title': t.title, 'symbol': t.symbol},
      ],
      'selected': selected,
      'visible': visible,
    };
    final key = args.toString();
    if (key == _lastTabsCall) return;
    _lastTabsCall = key;
    var shown = false;
    try {
      shown = await _channel.invokeMethod<bool>('setTabs', args) ?? false;
    } on MissingPluginException {
      shown = false;
    } on PlatformException {
      shown = false;
    }
    if (shown != _nativeTabsShown) {
      _nativeTabsShown = shown;
      notifyListeners();
    }
  }

  void _apply(Object? raw) {
    if (raw is Map) _setInfo(FoldInfo.fromMap(raw));
  }

  void _setInfo(FoldInfo next) {
    if (next == _info) return;
    _info = next;
    notifyListeners();
  }
}
