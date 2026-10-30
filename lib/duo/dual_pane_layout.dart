import 'dart:ui' show DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/widgets.dart';

import 'fold_info.dart';

/// How the two panes are arranged relative to the fold.
enum PaneAxis {
  /// Panes side by side (vertical fold / book posture).
  horizontal,

  /// Panes stacked (horizontal fold / tabletop posture).
  vertical,
}

/// Where the dual-pane decision came from (shown in the debug caption).
enum LayoutSource { single, displayFeature, reservedRegion, breakpoint }

@immutable
class DualPaneGeometry {
  const DualPaneGeometry._(this.source, this.axis, this.hinge);

  const DualPaneGeometry.single()
    : this._(LayoutSource.single, PaneAxis.horizontal, Rect.zero);

  final LayoutSource source;
  final PaneAxis axis;

  /// Area the content must avoid (fold, hinge or centre gutter), in view coordinates.
  final Rect hinge;

  bool get isDual => source != LayoutSource.single;

  /// Minimum width (logical px) before a fold-less screen is treated as an
  /// opened inner display. iPhone Duo inner display is ~951x669pt; its outer
  /// display and every slab iPhone stay well below this.
  static const double breakpoint = 840;

  /// Landscape phones are wide but short; only split when both panes keep
  /// enough height for the section content.
  static const double minDualHeight = 600;

  /// Gutter left around the centre crease when no fold region is reported.
  static const double centreGutter = 24;

  /// Order of precedence:
  /// 1. Flutter `MediaQuery.displayFeatures` (hinge / separating fold). Today
  ///    Flutter fills this only on Android, but it is the future-proof path
  ///    once iOS reserved regions are bridged by the engine.
  /// 2. iPhone Duo `.division` reserved region from the native bridge.
  /// 3. Width breakpoint: an opened, flat inner display splits at the crease.
  static DualPaneGeometry resolve(MediaQueryData mq, FoldInfo fold) {
    final size = mq.size;
    for (final f in mq.displayFeatures) {
      if (f.type == DisplayFeatureType.cutout) continue;
      final separating =
          !f.bounds.isEmpty ||
          f.type == DisplayFeatureType.hinge ||
          f.state == DisplayFeatureState.postureHalfOpened;
      if (!separating) continue;
      return DualPaneGeometry._(
        LayoutSource.displayFeature,
        _axisFor(f.bounds, size),
        f.bounds,
      );
    }

    final fold0 = fold.activeFold;
    if (fold0 != null) {
      return DualPaneGeometry._(
        LayoutSource.reservedRegion,
        _axisFor(fold0, size),
        fold0,
      );
    }

    if (size.width >= breakpoint &&
        size.height >= minDualHeight &&
        size.width > size.height) {
      final cx = size.width / 2;
      return DualPaneGeometry._(
        LayoutSource.breakpoint,
        PaneAxis.horizontal,
        Rect.fromLTWH(cx - centreGutter / 2, 0, centreGutter, size.height),
      );
    }
    return const DualPaneGeometry.single();
  }

  static PaneAxis _axisFor(Rect r, Size size) {
    if (r.width == 0 && r.height == 0) return PaneAxis.horizontal;
    // A tall, thin region is a vertical fold -> panes side by side.
    return r.height >= r.width ? PaneAxis.horizontal : PaneAxis.vertical;
  }

  @override
  bool operator ==(Object other) =>
      other is DualPaneGeometry &&
      other.source == source &&
      other.axis == axis &&
      other.hinge == hinge;

  @override
  int get hashCode => Object.hash(source, axis, hinge);
}

/// Lays [primary] and [secondary] out on either side of the fold so no
/// content (or touch target) sits in the folding region.
///
/// Each pane gets its own [MediaQuery] (its size, only the safe-area
/// padding of its own edges, and no display features) so descendants like
/// dialogs or the pill bar lay out for one screen only.
class DualPane extends StatelessWidget {
  const DualPane({
    super.key,
    required this.geometry,
    required this.primary,
    required this.secondary,
    this.hingeColor = const Color(0x00000000),
  });

  final DualPaneGeometry geometry;

  /// Leading (left) or bottom pane: navigation.
  final Widget primary;

  /// Trailing (right) or top pane: content.
  final Widget secondary;
  final Color hingeColor;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final h = geometry.hinge;

    Widget pane(Widget child, Size paneSize, EdgeInsets keep) {
      EdgeInsets clip(EdgeInsets e) => EdgeInsets.fromLTRB(
        keep.left > 0 ? e.left : 0,
        keep.top > 0 ? e.top : 0,
        keep.right > 0 ? e.right : 0,
        keep.bottom > 0 ? e.bottom : 0,
      );
      return MediaQuery(
        data: mq.copyWith(
          size: paneSize,
          padding: clip(mq.padding),
          viewPadding: clip(mq.viewPadding),
          viewInsets: clip(mq.viewInsets),
          displayFeatures: const [],
        ),
        child: SizedBox(
          width: paneSize.width,
          height: paneSize.height,
          child: child,
        ),
      );
    }

    if (geometry.axis == PaneAxis.horizontal) {
      final leftW = h.left.clamp(0.0, size.width);
      final rightW = (size.width - h.right).clamp(0.0, size.width);
      return Row(
        children: [
          pane(
            primary,
            Size(leftW, size.height),
            const EdgeInsets.fromLTRB(1, 1, 0, 1),
          ),
          SizedBox(
            width: (size.width - leftW - rightW),
            child: ColoredBox(color: hingeColor),
          ),
          pane(
            secondary,
            Size(rightW, size.height),
            const EdgeInsets.fromLTRB(0, 1, 1, 1),
          ),
        ],
      );
    }
    final topH = h.top.clamp(0.0, size.height);
    final bottomH = (size.height - h.bottom).clamp(0.0, size.height);
    return Column(
      children: [
        pane(
          secondary,
          Size(size.width, topH),
          const EdgeInsets.fromLTRB(1, 1, 1, 0),
        ),
        SizedBox(
          height: (size.height - topH - bottomH),
          child: ColoredBox(color: hingeColor),
        ),
        pane(
          primary,
          Size(size.width, bottomH),
          const EdgeInsets.fromLTRB(1, 0, 1, 1),
        ),
      ],
    );
  }
}
