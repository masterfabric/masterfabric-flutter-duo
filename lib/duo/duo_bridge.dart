import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'fold_info.dart';

/// Listens to the native `masterfabric/duo` channel (see ios/Runner/AppDelegate.swift).
///
/// Re-queries whenever the window metrics change (fold/unfold resizes the
/// app on iPhone Duo) and accepts pushes from `UIHingeInteraction`.
class DuoBridge extends ChangeNotifier with WidgetsBindingObserver {
  DuoBridge._();

  static final DuoBridge instance = DuoBridge._();
  static const _channel = MethodChannel('masterfabric/duo');

  FoldInfo _info = FoldInfo.none;
  FoldInfo get info => _info;

  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'update') _apply(call.arguments);
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

  Future<void> refresh() async {
    try {
      _apply(await _channel.invokeMethod<Object?>('getState'));
    } on MissingPluginException {
      // Not running with the native bridge (e.g. tests, other platforms).
    } on PlatformException {
      // Ignore: fall back to Flutter display features / breakpoints.
    }
  }

  @visibleForTesting
  void debugSet(FoldInfo info) => _setInfo(info);

  void _apply(Object? raw) {
    if (raw is Map) _setInfo(FoldInfo.fromMap(raw));
  }

  void _setInfo(FoldInfo next) {
    if (next == _info) return;
    _info = next;
    notifyListeners();
  }
}
