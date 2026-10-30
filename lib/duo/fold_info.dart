import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';

/// Hinge status as reported by UIKit's `UIHinge.Status` (iOS 27.1+).
enum HingeStatus { none, unknown, closed, partiallyOpen, fullyOpen }

/// A UIKit reserved region (`UIView.ReservedRegion`), in logical pixels
/// relative to the Flutter view.
@immutable
class ReservedRegion {
  const ReservedRegion(this.rect, {required this.active});

  final Rect rect;
  final bool active;

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
  const FoldInfo({
    this.supported = false,
    this.hinge = HingeStatus.none,
    this.angle = -1,
    this.divisions = const [],
    this.occlusions = const [],
  });

  /// True when the native side runs on iOS 27.1+ (reserved-region APIs exist).
  final bool supported;
  final HingeStatus hinge;

  /// Hinge angle in degrees (0 = shut, 180 = flat); -1 when unknown.
  final double angle;
  final List<ReservedRegion> divisions;
  final List<ReservedRegion> occlusions;

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
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FoldInfo &&
      other.supported == supported &&
      other.hinge == hinge &&
      (other.angle - angle).abs() < 1 &&
      listEquals(other.divisions, divisions) &&
      listEquals(other.occlusions, occlusions);

  @override
  int get hashCode => Object.hash(
    supported,
    hinge,
    angle.round(),
    Object.hashAll(divisions),
    Object.hashAll(occlusions),
  );
}
