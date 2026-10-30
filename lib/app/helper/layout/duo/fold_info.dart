import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';

/// Hinge status as reported by UIKit's `UIHinge.Status` (iOS 27.1+).
enum HingeStatus {
  /// Not a foldable (or no native bridge).
  none,

  /// Foldable, state not reported yet.
  unknown,

  /// Folded: only the outer display is in use.
  closed,

  /// Partly open (book / tabletop).
  partiallyOpen,

  /// Fully open, flat.
  fullyOpen,
}

/// `UITraitCollection.verticalBarEdge` (iOS 27.1+): the edge where the
/// system places its vertical bar (status bar / toolbars) on iPhone Duo.
enum VerticalBarEdge {
  /// No vertical bar (regular iPhone layout).
  unspecified,

  /// Bar on the leading edge.
  leading,

  /// Bar on the trailing edge.
  trailing,
}

/// How the opened device is being held, derived from the hinge and fold.
enum DuoPosture {
  /// No hinge information (slab iPhone, simulator without hinge, tests).
  unknown,

  /// Opened and laid flat (`UIHinge.Status.fullyOpen`).
  flat,

  /// Partially open with a vertical fold: side-by-side panes like a book.
  book,

  /// Partially open with a horizontal fold: laptop / tabletop posture.
  tabletop,

  /// Closed: the app runs on the outer display.
  closed,
}

/// A UIKit reserved region (`UIView.ReservedRegion`), in logical pixels
/// relative to the Flutter view.
@immutable
class ReservedRegion {
  /// Creates a region covering [rect].
  const ReservedRegion(this.rect, {required this.active});

  /// Region in the Flutter view, in logical pixels.
  final Rect rect;

  /// Whether the region is currently active (e.g. camera housing in use).
  final bool active;

  /// Parses a `{x, y, width, height, active}` channel map.
  static ReservedRegion? fromMap(Object? raw) {
    if (raw is! Map) return null;
    double v(String k) => (raw[k] as num?)?.toDouble() ?? 0;
    return ReservedRegion(
      Rect.fromLTWH(v('x'), v('y'), v('width'), v('height')),
      active: raw['active'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReservedRegion && other.rect == rect && other.active == active;

  @override
  int get hashCode => Object.hash(rect, active);
}

/// Snapshot of the iPhone Duo fold state bridged from native code.
@immutable
class FoldInfo {
  /// Creates fold info; defaults describe a non-Duo device.
  const FoldInfo({
    this.supported = false,
    this.hinge = HingeStatus.none,
    this.angle = -1,
    this.divisions = const [],
    this.occlusions = const [],
    this.verticalBarEdge = VerticalBarEdge.unspecified,
  });

  /// True when the native side runs on iOS 27.1+ (reserved-region APIs exist).
  final bool supported;

  /// Hinge state from `UIHingeInteraction`.
  final HingeStatus hinge;

  /// Hinge angle in degrees (0 = shut, 180 = flat); -1 when unknown.
  final double angle;

  /// `reservedRegions(kind: .division)`: the fold line(s).
  final List<ReservedRegion> divisions;

  /// `reservedRegions(kind: .occlusion)`: camera housings etc.
  final List<ReservedRegion> occlusions;

  /// Where UIKit puts its vertical bar; app chrome goes on the other side.
  final VerticalBarEdge verticalBarEdge;

  /// No Duo hardware / no native bridge.
  static const none = FoldInfo();

  /// The fold that currently divides the view, if any.
  ///
  /// Apple: a division is active only while iPhone Duo is partially open.
  /// `isActive` can lag the hinge right after the device is laid flat, so a
  /// division is ignored once the hinge reports fully open or closed.
  Rect? get activeFold {
    if (hinge == HingeStatus.fullyOpen || hinge == HingeStatus.closed) {
      return null;
    }
    for (final d in divisions) {
      if (d.active && !d.rect.isEmpty) return d.rect;
    }
    return null;
  }

  /// Camera housings that currently cover the view (the inner camera is only
  /// active while in use; the outer camera always is).
  Iterable<Rect> get activeOcclusions =>
      occlusions.where((o) => o.active && !o.rect.isEmpty).map((o) => o.rect);

  /// The fold position even while it is inactive (zero width when flat).
  /// Apple recommends using inactive regions to avoid layout jumps when the
  /// device starts to fold.
  Rect? get anyDivision => divisions.isEmpty ? null : divisions.first.rect;

  /// Posture derived from hinge state and angle.
  DuoPosture get posture {
    switch (hinge) {
      case HingeStatus.closed:
        return DuoPosture.closed;
      case HingeStatus.fullyOpen:
        return DuoPosture.flat;
      case HingeStatus.partiallyOpen:
        final f = activeFold;
        if (f != null && f.width > f.height) return DuoPosture.tabletop;
        return DuoPosture.book;
      case HingeStatus.none:
      case HingeStatus.unknown:
        return DuoPosture.unknown;
    }
  }

  /// Parses the `getState` / `update` channel payload.
  factory FoldInfo.fromMap(Map<Object?, Object?> m) {
    List<ReservedRegion> regions(Object? raw) => raw is List
        ? raw.map(ReservedRegion.fromMap).whereType<ReservedRegion>().toList()
        : const [];
    return FoldInfo(
      supported: m['supported'] == true,
      hinge: HingeStatus.values.firstWhere(
        (s) => s.name == m['hinge'],
        orElse: () => HingeStatus.unknown,
      ),
      angle: (m['angle'] as num?)?.toDouble() ?? -1,
      divisions: regions(m['divisions']),
      occlusions: regions(m['occlusions']),
      verticalBarEdge: VerticalBarEdge.values.firstWhere(
        (e) => e.name == m['verticalBarEdge'],
        orElse: () => VerticalBarEdge.unspecified,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FoldInfo &&
      other.supported == supported &&
      other.hinge == hinge &&
      (other.angle - angle).abs() < 1 &&
      listEquals(other.divisions, divisions) &&
      listEquals(other.occlusions, occlusions) &&
      other.verticalBarEdge == verticalBarEdge;

  @override
  int get hashCode => Object.hash(
    supported,
    hinge,
    angle.round(),
    Object.hashAll(divisions),
    Object.hashAll(occlusions),
    verticalBarEdge,
  );
}
