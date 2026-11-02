import 'package:equatable/equatable.dart';
import 'package:hello_flutter/app/helper/layout/duo/fold_info.dart';

/// Events handled by `DuoBloc`.
sealed class DuoEvent extends Equatable {
  /// Base constructor.
  const DuoEvent();

  @override
  List<Object?> get props => [];
}

/// The `DuoBridge` reported a new posture or native tab bar visibility.
/// Carries a snapshot so every bridge notification maps to one state.
final class DuoBridgeChanged extends DuoEvent {
  /// Creates the event from the bridge's [info] and [nativeTabsShown].
  const DuoBridgeChanged({required this.info, required this.nativeTabsShown});

  /// Hinge, reserved regions and vertical bar edge.
  final FoldInfo info;

  /// Whether the native side tab bar is the navigation right now.
  final bool nativeTabsShown;

  @override
  List<Object?> get props => [info, nativeTabsShown];
}

/// Hand navigation to the native side tab bar while [visible] (closed
/// iPhone Duo) and keep its [selected] tab in sync.
final class DuoNativeTabsSyncRequested extends DuoEvent {
  /// Creates the request.
  const DuoNativeTabsSyncRequested({
    required this.tabs,
    required this.selected,
    required this.visible,
  });

  /// Tab titles and SF Symbol names, in section order.
  final List<({String title, String symbol})> tabs;

  /// Selected tab index.
  final int selected;

  /// Whether the native tab bar should be shown.
  final bool visible;

  @override
  List<Object?> get props => [tabs, selected, visible];
}
