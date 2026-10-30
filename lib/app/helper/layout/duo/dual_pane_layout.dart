import 'dart:math' as math;
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

  /// Hairline seam drawn at the crease when the device is open flat. Apple:
  /// the division is inactive (zero width) when fully open, so content may
  /// run right up to the centre; only an active fold needs a real gap.
  static const double seam = 1;

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
      // Split exactly where the (inactive) division sits so nothing jumps
      // sideways when the person starts folding the device.
      final d = fold.anyDivision;
      final cx =
          d != null &&
              d.height >= d.width &&
              d.center.dx > 0 &&
              d.center.dx < size.width
          ? d.center.dx
          : size.width / 2;
      return DualPaneGeometry._(
        LayoutSource.breakpoint,
        PaneAxis.horizontal,
        Rect.fromLTWH(cx - seam / 2, 0, seam, size.height),
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
    this.occlusions = const [],
  });

  final DualPaneGeometry geometry;

  /// Leading (left) or bottom pane: navigation.
  final Widget primary;

  /// Trailing (right) or top pane: content.
  final Widget secondary;
  final Color hingeColor;

  /// Active camera housings (UIKit `.occlusion` regions) in view coordinates;
  /// each pane pads itself away from the ones it overlaps.
  final List<Rect> occlusions;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final h = geometry.hinge;

    // Each pane's background bleeds to the centre of the fold; the fold
    // half on its side becomes padding so only content keeps clear of it.
    Widget pane(
      Widget child,
      Offset origin,
      Size paneSize,
      EdgeInsets keep,
      EdgeInsets fold,
    ) {
      EdgeInsets clip(EdgeInsets e) => EdgeInsets.fromLTRB(
        keep.left > 0 ? e.left : 0,
        keep.top > 0 ? e.top : 0,
        keep.right > 0 ? e.right : 0,
        keep.bottom > 0 ? e.bottom : 0,
      );
      final rect = origin & paneSize;
      final safe = clip(mq.padding) + fold;
      final occ = occlusionInsets(rect, occlusions, safe);
      return MediaQuery(
        data: mq.copyWith(
          size: paneSize,
          padding: maxInsets(safe, occ),
          viewPadding: maxInsets(clip(mq.viewPadding) + fold, occ),
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
      final half = (size.width - leftW - rightW) / 2;
      return Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: hingeColor)),
          Row(
            children: [
              pane(
                primary,
                Offset.zero,
                Size(leftW + half, size.height),
                const EdgeInsets.fromLTRB(1, 1, 0, 1),
                EdgeInsets.only(right: half),
              ),
              pane(
                secondary,
                Offset(size.width - rightW - half, 0),
                Size(rightW + half, size.height),
                const EdgeInsets.fromLTRB(0, 1, 1, 1),
                EdgeInsets.only(left: half),
              ),
            ],
          ),
        ],
      );
    }
    final topH = h.top.clamp(0.0, size.height);
    final bottomH = (size.height - h.bottom).clamp(0.0, size.height);
    final half = (size.height - topH - bottomH) / 2;
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: hingeColor)),
        Column(
          children: [
            pane(
              secondary,
              Offset.zero,
              Size(size.width, topH + half),
              const EdgeInsets.fromLTRB(1, 1, 1, 0),
              EdgeInsets.only(bottom: half),
            ),
            pane(
              primary,
              Offset(0, size.height - bottomH - half),
              Size(size.width, bottomH + half),
              const EdgeInsets.fromLTRB(1, 0, 1, 1),
              EdgeInsets.only(top: half),
            ),
          ],
        ),
      ],
    );
  }
}

/// Insets that keep content inside [pane] clear of the [occlusions] it
/// overlaps (e.g. the iPhone Duo camera housings). Regions already inside
/// the system safe area ([safe], in pane-local insets) cost nothing; every
/// other region pushes in whichever pane edge clears it most cheaply.
EdgeInsets occlusionInsets(
  Rect pane,
  Iterable<Rect> occlusions, [
  EdgeInsets safe = EdgeInsets.zero,
]) {
  var l = 0.0, t = 0.0, r = 0.0, b = 0.0;
  final usable = safe.deflateRect(pane);
  for (final o in occlusions) {
    final i = usable.intersect(o);
    if (i.width <= 0 || i.height <= 0) continue;
    final top = i.bottom - pane.top;
    final bottom = pane.bottom - i.top;
    final left = i.right - pane.left;
    final right = pane.right - i.left;
    final m = [top, bottom, left, right].reduce(math.min);
    if (m == top) {
      t = math.max(t, top);
    } else if (m == bottom) {
      b = math.max(b, bottom);
    } else if (m == left) {
      l = math.max(l, left);
    } else {
      r = math.max(r, right);
    }
  }
  return EdgeInsets.fromLTRB(l, t, r, b);
}

/// Component-wise maximum of two insets.
EdgeInsets maxInsets(EdgeInsets a, EdgeInsets b) => EdgeInsets.fromLTRB(
  math.max(a.left, b.left),
  math.max(a.top, b.top),
  math.max(a.right, b.right),
  math.max(a.bottom, b.bottom),
);
