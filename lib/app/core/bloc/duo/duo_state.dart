import 'package:equatable/equatable.dart';
import 'package:hello_flutter/app/helper/layout/duo/fold_info.dart';

/// iPhone Duo posture as reported by the native `masterfabric/duo` bridge.
final class DuoState extends Equatable {
  /// Creates a state from the fold [info] and native tab bar visibility.
  const DuoState({this.info = FoldInfo.none, this.nativeTabsShown = false});

  /// Hinge, reserved regions and vertical bar edge.
  final FoldInfo info;

  /// Whether the native side tab bar is the navigation right now.
  final bool nativeTabsShown;

  @override
  List<Object?> get props => [info, nativeTabsShown];
}
